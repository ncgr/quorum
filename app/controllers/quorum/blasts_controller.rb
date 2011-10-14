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

      if file
        @blast.sequence = ""
        @blast.sequence << file
      end

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
      redirect_to blast_path(@blast.id)
    end

    def show
      order_by = check_kaminari_sort(BlastReport, params[:sort], params[:dir])
      @blast_reports = BlastReport.where(
        {:blast_id => params[:id]}
      ).order(order_by).page(params[:page])
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

      logger.info @blast.inspect
      ## Optional Quorum params ##
      cmd << "-v #{@blast.expectation} " unless @blast.expectation.blank?
      cmd << "-c #{@blast.max_score} " unless @blast.max_score.blank?
      cmd << "-j #{@blast.min_bit_score} " unless @blast.min_bit_score.blank?
      cmd << "-g " unless @blast.gapped_alignments.blank?

      if @blast.gap_opening_penalty
        cmd << "-o #{@blast.gap_opening_penalty} "
      end

      if @blast.gap_extension_penalty
        cmd << "-y #{@blast.gap_extension_penalty} "
      end

      @exit_status = execute_cmd(
        cmd, Quorum.blast_remote, Quorum.blast_ssh_host,
        Quorum.blast_ssh_user, Quorum.blast_ssh_options
      )
    end
  end
end
