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

      if @job.save
        Resque.enqueue(Blastn, @job.blastn_job.id)   if @job.blastn_job.queue
        Resque.enqueue(Blastx, @job.blastx_job.id)   if @job.blastx_job.queue
        Resque.enqueue(Tblastn, @job.tblastn_job.id) if @job.tblastn_job.queue
        Resque.enqueue(Blastp, @job.blastp_job.id)   if @job.blastp_job.queue
        Resque.enqueue(Hmmer, @job.hmmer_job.id)     if @job.hmmer_job.queue
      else
        render :action => "new"
        return 
      end
      redirect_to job_path(@job.id)
    end

    def show
      @jobs = Job.find(params[:id])
    end

    private

    #
    # Create system commands based on config/quorum_settings.yml
    #
    def create_system_command
      tblastn = blastp = blastn = blastx = hmmer = nil

      # System command
      cmd = "#{Quorum.blast_script} -s blast -i #{@job.id} " <<
        "-e #{::Rails.env.to_s} -l #{Quorum.blast_log_dir} " <<
        "-m #{Quorum.blast_tmp_dir} " <<
        "-d #{ActiveRecord::Base.configurations[::Rails.env.to_s]['database']} " <<
        "-a #{ActiveRecord::Base.configurations[::Rails.env.to_s]['adapter']} " <<
        "-k #{ActiveRecord::Base.configurations[::Rails.env.to_s]['host']} " <<
        "-u #{ActiveRecord::Base.configurations[::Rails.env.to_s]['username']} " <<
        "-p #{ActiveRecord::Base.configurations[::Rails.env.to_s]['password']} " <<
        "-b #{Quorum.blast_db} -t #{Quorum.blast_threads} "

      ## Optional Quorum collections ##
      unless Quorum.tblastn.empty?
        tblastn = Quorum.tblastn.join(';')
        cmd << "-q " << tblastn << " "
      end
      unless Quorum.blastp.empty?
        blastp = Quorum.blastp.join(';')
        cmd << "-r " << blastp << " "
      end
      unless Quorum.blastn.empty?
        blastn = Quorum.blastn.join(';')
        cmd << "-n " << blastn << " "
      end
      unless Quorum.blastx.empty?
        blastx = Quorum.blastx.join(';')
        cmd << "-x " << blastx << " "
      end

      logger.info @job.inspect
      ## Optional Quorum params ##
      cmd << "-v #{@job.expectation} " unless @job.expectation.blank?
      cmd << "-c #{@job.max_score} " unless @job.max_score.blank?
      cmd << "-j #{@job.min_bit_score} " unless @job.min_bit_score.blank?
      cmd << "-g " unless @job.gapped_alignments.blank?

      if @job.gap_opening_penalty
        cmd << "-o #{@job.gap_opening_penalty} "
      end

      if @job.gap_extension_penalty
        cmd << "-y #{@job.gap_extension_penalty} "
      end

      @exit_status = execute_cmd(
        cmd, Quorum.blast_remote, Quorum.blast_ssh_host,
        Quorum.blast_ssh_user, Quorum.blast_ssh_options
      )
    end

    #
    # Blast Database options for select.
    #
    def set_blast_dbs
      @blast_dbs = [
        Quorum.blastn << Quorum.blastn.first, 
        Quorum.blastx << Quorum.blastx.first, 
        Quorum.tblastn << Quorum.tblastn.first, 
        Quorum.blastp << Quorum.blastp.first
      ]
      @blast_dbs.uniq!(&:first)
      all = []
      @blast_dbs.each {|d| all << d.first}
      @blast_dbs.unshift ['All Databases', all.join(',')]
    end

  end
end
