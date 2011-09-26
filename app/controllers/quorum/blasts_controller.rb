module Quorum
  class BlastsController < ApplicationController
    def index
      redirect_to :action => "new"
    end

    def new
      @blast = Blast.new
    end

    def create
      if params[:blast][:sequence_file]
        file = params[:blast][:sequence_file].read
        params[:blast].delete(:sequence_file)
      end

      @blast = Blast.new(params[:blast])

      @blast.sequence << file if file

      begin
        ActiveSupport::Multibyte::Unicode.u_unpack(@blast.sequence)
      rescue ActiveSupport::Multibyte::EncodingError => e
        logger.error e.message
        set_flash_message(:error, :error_encoding)
        redirect_to :action => "new"
        return
      end

      if @blast.save
        execute_system_command
        if @exit_status.to_s != :error_0.to_s
          @blast.destroy
          set_flash_message(:error, @exit_status)
          redirect_to :action => "new"
          return
        end
      else
        render :action => "new"
        return 
      end
      redirect_to blast_path(@blast)
    end

    def show
      @blast = Blast.find(params[:id])
    end

    private

    #
    # Execute system command based on config/quorum_settings.yml
    #
    def execute_system_command
      tblastn = blastp = blastn = blastx = nil

      # System command
      cmd = "#{Quorum.blast_script} -s blast -i #{@blast.id} " <<
        "-e #{::Rails.env.to_s} -l #{Quorum.blast_log_dir} " <<
        "-m #{Quorum.blast_tmp_dir} " <<
        "-d #{ActiveRecord::Base.configurations[::Rails.env.to_s]['database']} " <<
        "-a #{ActiveRecord::Base.configurations[::Rails.env.to_s]['adapter']} " <<
        "-k #{ActiveRecord::Base.configurations[::Rails.env.to_s]['host']} " <<
        "-u #{ActiveRecord::Base.configurations[::Rails.env.to_s]['username']} " <<
        "-p #{ActiveRecord::Base.configurations[::Rails.env.to_s]['password']} " <<
        "-b #{Quorum.blast_db} -t #{Quorum.blast_threads} "

      ## Optional Quorum. collections ##
      unless Quorum.tblastn.nil?
        tblastn = Quorum.tblastn.join(';')
        cmd << "-q " << tblastn << " "
      end
      unless Quorum.blastp.nil?
        blastp = Quorum.blastp.join(';')
        cmd << "-r " << blastp << " "
      end
      unless Quorum.blastn.nil?
        blastn = Quorum.blastn.join(';')
        cmd << "-n " << blastn << " "
      end
      unless Quorum.blastx.nil?
        blastx = Quorum.blastx.join(';')
        cmd << "-x " << blastx << " "
      end

      @exit_status = execute_cmd(
        cmd, Quorum.blast_remote, Quorum.blast_ssh_host,
        Quorum.blast_ssh_user, Quorum.blast_ssh_options
      )
    end
  end
end
