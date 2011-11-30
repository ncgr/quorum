module Quorum
  class JobsController < ApplicationController

    before_filter :set_blast_dbs, :only => [:new, :create]

    def index
      redirect_to :action => "new"
    end

    def new
      @job = Job.new
      @job.build_blastn_job
      @job.build_blastx_job
      @job.build_tblastn_job
      @job.build_blastp_job
      @job.build_hmmer_job
    end

    def create
      if params[:job][:sequence_file]
        file = params[:job][:sequence_file].read
        params[:job].delete(:sequence_file)
      end

      @job = Job.new(params[:job])

      if file
        @job.sequence = ""
        @job.sequence << file
      end

      unless @job.save
        @job.build_blastn_job  if @job.blastn_job.nil?
        @job.build_blastx_job  if @job.blastx_job.nil?
        @job.build_tblastn_job if @job.tblastn_job.nil?
        @job.build_blastp_job  if @job.blastp_job.nil?
        @job.build_hmmer_job   if @job.hmmer_job.nil?
        render :action => "new"
        return 
      end
      redirect_to job_path(@job.id)
    end

    def show
      @jobs = Job.find(params[:id])
    end

    #
    # Returns Resque worker results.
    #
    def get_quorum_search_results
      valid = ["blastn", "blastx", "tblastn", "blastp", "hmmer"]
      empty = [{:results => false}].to_json

      json = empty

      if valid.include? params[:algo]
        queued = "#{params[:algo]}_job".to_sym
        report = "#{params[:algo]}_job_reports".to_sym

	      begin
	        job = Job.find(params[:id])
	      rescue ActiveRecord::RecordNotFound => e
	        json = empty
	      else
	        if job.method(queued).call.present?
	          if job.method(report).call.present?
              json = job.method(report).call.default_order
            else
              json = []
            end
	        end
	      end
      end

      respond_to do |format|
        format.json { 
          render :json => json
        }
      end
    end

    private

    #
    # Blast Database options for select.
    #
    def set_blast_dbs
      @blast_dbs = {
        :blastn  => Quorum.blastn,
        :blastx  => Quorum.blastx, 
        :tblastn => Quorum.tblastn, 
        :blastp  => Quorum.blastp
      }
    end

  end
end
