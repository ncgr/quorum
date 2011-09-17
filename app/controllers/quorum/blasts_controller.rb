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

      @blast.sequence = file if @blast.sequence.blank?

      begin
        ActiveSupport::Multibyte::Unicode.u_unpack(@blast.sequence)
      rescue ActiveSupport::Multibyte::EncodingError => e
        logger.error e.message
        set_flash_message(:error, :encoding_error)
        redirect_to :action => "new"
        return
      end

      if @blast.save
        execute_system_command
        if @exit_status != :error_0
          #@blast.destroy
          set_flash_message(:error, @exit_status)
          redirect_to :action => "new"
          return
        end
      else
        set_flash_message(:error, :save_error)
        redirect_to :action => "new"
        return 
      end
      redirect_to blasts_path(@blast)
    end

    def show
      @blast = Blast.find(params[:id])
    end

    private

    #
    # Execute system command based on config/quorum_settings.yml
    #
    def execute_system_command
      @exit_status = :error_75  # Default failure.

      tblastn = blastp = blastn = blastx = nil

      # System command
      cmd = "#{QUORUM['blast']['script']} " <<
        "-s blast -i #{@blast.id} " <<
        "-e #{::Rails.env.to_s} -l #{QUORUM['blast']['log_dir']} " <<
        "-d #{ActiveRecord::Base.configurations[::Rails.env.to_s]['database']} " <<
        "-a #{ActiveRecord::Base.configurations[::Rails.env.to_s]['adapter']} " <<
        "-k #{ActiveRecord::Base.configurations[::Rails.env.to_s]['host']} " <<
        "-u #{ActiveRecord::Base.configurations[::Rails.env.to_s]['username']} " <<
        "-p #{ActiveRecord::Base.configurations[::Rails.env.to_s]['password']} " <<
        "-b #{QUORUM['blast']['blast_db']} " <<
        "-t #{QUORUM['blast']['blast_threads']} "

      ## Optional QUORUM['blast'] collections ##
      unless QUORUM['blast']['tblastn'].nil?
        tblastn = QUORUM['blast']['tblastn'].join(';')
        cmd << "-q " << tblastn << " "
      end
      unless QUORUM['blast']['blastp'].nil?
        blastp = QUORUM['blast']['blastp'].join(';')
        cmd << "-r " << blastp << " "
      end
      unless QUORUM['blast']['blastn'].nil?
        blastn = QUORUM['blast']['blastn'].join(';')
        cmd << "-n " << blastn << " "
      end
      unless QUORUM['blast']['blastx'].nil?
        blastx = QUORUM['blast']['blastx'].join(';')
        cmd << "-x " << blastx << " "
      end

      logger.debug "\n-- quorum command --\n" + cmd + "\n\n"

      if QUORUM['blast']['remote']
        # Execute the script on the remote machine.
        Net::SSH.start(QUORUM['blast']['ssh_host'], 
                       QUORUM['blast']['ssh_user'],
                       QUORUM['blast']['ssh_options']) do |ssh|
          ssh.open_channel do |ch|
            ch.exec(cmd) do |ch, success|
              unless success 
                puts "Channel exec() failed. :("
              else
                # Read the exit status of the remote process.
                ch.on_request("exit-status") do |ch, data|
                  @exit_status = data.read_long
                end
              end
            end
          end
          ssh.loop
        end
      else
        system(cmd)
        @exit_status = $?.exitstatus
      end
      @exit_status = "error_" + @exit_status.to_s
      @exit_status.to_sym
    end
  end
end
