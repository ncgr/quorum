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
        if @job.blastn_job && @job.blastn_job.queue
          create_system_command("blastn")
          Resque.enqueue(Workers::Blast, @cmd, Quorum.blast_remote, 
                         Quorum.blast_ssh_host, Quorum.blast_ssh_user, 
                         Quorum.blast_ssh_options)
        end
        if @job.blastx_job && @job.blastx_job.queue
          create_system_command("blastx")
          Resque.enqueue(Workers::Blast, @cmd, Quorum.blast_remote, 
                         Quorum.blast_ssh_host, Quorum.blast_ssh_user, 
                         Quorum.blast_ssh_options)

        end
        if @job.tblastn_job && @job.tblastn_job.queue
          create_system_command("tblastn")
          Resque.enqueue(Workers::Blast, @cmd, Quorum.blast_remote, 
                         Quorum.blast_ssh_host, Quorum.blast_ssh_user, 
                         Quorum.blast_ssh_options)
        end
        if @job.blastp_job && @job.blastp_job.queue
          create_system_command("blastp")
          Resque.enqueue(Workers::Blast, @cmd, Quorum.blast_remote, 
                         Quorum.blast_ssh_host, Quorum.blast_ssh_user, 
                         Quorum.blast_ssh_options)
        end
        if @job.hmmer_job && @job.hmmer_job.queue
          create_system_command("hmmscan")
          Resque.enqueue(Workers::Hmmer, @cmd, Hmmer.blast_remote, 
                         Hmmer.blast_ssh_host, Hmmer.blast_ssh_user, 
                         Hmmer.blast_ssh_options)
        end
      else
        render :action => "new"
        return 
      end
      redirect_to job_path(@job.id)
    end

    def show
      @jobs = Job.find(params[:id])
    end

    def get_results
      @results = Job.find(params[:id])
      respond_to do |format|
        format.json { render :json => @results.blastn_job_reports }
      end
    end

    private

    #
    # Create system commands based on config/quorum_settings.yml
    #
    def create_system_command(algorithm)
      # System command
      @cmd = ""

      if Quorum::BLAST_ALGORITHMS.include?(algorithm)
        @cmd << "#{Quorum.blast_script} -l #{Quorum.blast_log_dir} " <<
          "-m #{Quorum.blast_tmp_dir} -b #{Quorum.blast_db} " <<
          "-t #{Quorum.blast_threads} "
      elsif Quorum::HMMER_ALGORITHMS.include?(algorithm)
        @cmd << "#{Quorum.hmmer_script} -l #{Quorum.hmmer_log_dir} " <<
          "-m #{Quorum.hmmer_tmp_dir} -b #{Quorum.hmmer_db} " <<
          "-t #{Quorum.hmmer_threads} "
      else
        raise "Algorithm not found: #{algorithm}"
      end

      @cmd << "-s #{algorithm} -i #{@job.id} " <<
        "-d #{ActiveRecord::Base.configurations[::Rails.env.to_s]['database']} " <<
        "-a #{ActiveRecord::Base.configurations[::Rails.env.to_s]['adapter']} " <<
        "-k #{ActiveRecord::Base.configurations[::Rails.env.to_s]['host']} " <<
        "-u #{ActiveRecord::Base.configurations[::Rails.env.to_s]['username']} " <<
        "-p #{ActiveRecord::Base.configurations[::Rails.env.to_s]['password']} "
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
