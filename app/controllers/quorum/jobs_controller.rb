module Quorum
  class JobsController < ApplicationController

    respond_to :html, :json, :gff, :txt
    before_filter :set_blast_dbs, :only => [:new, :create]

    def index
      redirect_to :action => "new"
    end

    def new
      build_blast_jobs
    end

    def create
      read_sequence_file
      @job = Job.new(params[:job])
      set_sequence

      unless @job.save
        build_blast_jobs
        render :action => "new"
        return
      end
      redirect_to job_path(@job.id)
    end

    def show
      begin
        @jobs = Job.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        set_flash_message(:notice, :data_not_found)
        redirect_to :action => "new"
      end
    end

    #
    # Returns Quorum's search results.
    #
    # This method should be used to gather Resque worker results, or user
    # supplied query params.
    #
    def search_results
      data = Job.search_results(params)
      # Respond with :json, :txt (tab delimited Blast results), or GFF3.
      respond_with data.flatten!(1) do |format|
        format.json {
          render :json => Quorum::JobSerializer.as_json(data)
        }
        format.gff {
          render :text => Quorum::JobSerializer.as_gff(data)
        }
        format.txt {
          render :text => Quorum::JobSerializer.as_txt(data)
        }
      end
    end

    #
    # Find hit sequence, queue worker and return worker meta_id
    # for lookup.
    #
    def get_blast_hit_sequence
      if Quorum::BLAST_ALGORITHMS.include?(params[:algo])
        begin
          job = Job.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          logger.error e.message
        else
          data = job.fetch_quorum_blast_sequence(
            params[:algo], params[:algo_id]
          )
          json = [{ :meta_id => data.meta_id }]
        end
      end

      respond_with json || []
    end

    #
    # Send Blast hit sequence as attached file or render
    # error message as text.
    #
    # See lib/generators/templates/blast_db.rb for more info.
    #
    def send_blast_hit_sequence
      data = Workers::System.get_meta(params[:meta_id])
      if data.succeeded?
        if data.result.downcase.include?("error")
          render :text => data.result
          return
        else
          send_data data.result,
            :filename    => "#{params[:meta_id]}.fa",
            :type        => "text/plain",
            :disposition => "attachment"
          return
        end
      end
      render :text => ""
    end

    private

    #
    # Create new Job and build associations.
    #
    def build_blast_jobs
      @job ||= Job.new
      @job.build_blastn_job  if @job.blastn_job.nil?
      @job.build_blastx_job  if @job.blastx_job.nil?
      @job.build_tblastn_job if @job.tblastn_job.nil?
      @job.build_blastp_job  if @job.blastp_job.nil?
    end

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

    #
    # Read and remove uploaded sequence file from params.
    #
    def read_sequence_file
      if params[:job][:sequence_file]
        @file = params[:job][:sequence_file].read
        params[:job].delete(:sequence_file)
      end
    end

    #
    # Set uploaded sequence file.
    #
    def set_sequence
      if @file
        @job.sequence = ""
        @job.sequence << @file
      end
      @file = nil
    end

  end
end
