module Workers
  class System

    extend Resque::Plugins::Result

    @queue = :system_queue

    #
    # Resque worker method.
    #
    def self.perform(meta_id, cmd, remote, ssh_host, ssh_user, ssh_options = {}, stdout = false)
      @meta_id     = meta_id
      @cmd         = cmd
      @remote      = remote
      @ssh_host    = ssh_host
      @ssh_user    = ssh_user
      @ssh_options = ssh_options
      @stdout      = stdout
      @exit_status = 1
      @out         = ""

      self.set_ssh_options

      if remote
        self.execute_ssh
      else
        @out         = `#{@cmd}`
        @exit_status = $?.exitstatus
      end

      if @exit_status > 0
        raise "Worker failed :'(. See quorum/log/quorum.log for more information."
      end

      @out if stdout
    end

    #
    # Convert each key in ssh_options to a symbol.
    #
    def self.set_ssh_options
      unless @ssh_options.empty?
        @ssh_options = @ssh_options.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
        memo
        end
      end
    end

    #
    # Execute command on remote machine.
    #
    def self.execute_ssh
      Net::SSH.start(@ssh_host, @ssh_user, @ssh_options) do |ssh|
        ssh.open_channel do |ch|
          ch.exec(@cmd) do |ch, success|
            if success
              # Capture STDOUT from ch.exec()
              if @stdout
                ch.on_data do |ch, data|
                  @out = data
                end
              end
              # Read the exit status of the remote process.
              ch.on_request("exit-status") do |ch, data|
                @exit_status = data.read_long
              end
            else
              Rails.logger.warn "Channel Net::SSH exec() failed. :'("
            end
          end
        end
        ssh.loop
      end
    end

    #
    # Create fetch command based on config/quorum_settings.yml
    #
    def self.create_blast_fetch_command(db_names, hit_id, hit_display_id, algo)
      # System command
      cmd = ""

      fetch = File.join(Quorum.blast_bin, "fetch")
      cmd << "#{fetch} -f blastdbcmd -l #{Quorum.blast_log_dir} " <<
        "-m #{Quorum.blast_tmp_dir} -d #{Quorum.blast_db} " <<
        "-n '#{db_names}' -b '#{hit_id}' -s '#{hit_display_id}' " <<
        "-a #{algo}"
    end

    #
    # Create search command based on config/quorum_settings.yml
    #
    def self.create_search_command(algo, id)
      # System command
      cmd = ""
      return cmd unless Quorum::SUPPORTED_ALGORITHMS.include?(algo)

      case
      when Quorum::BLAST_ALGORITHMS.include?(algo)
        search = File.join(Quorum.blast_bin, "search")
        cmd << "#{search} -l #{Quorum.blast_log_dir} " <<
          "-m #{Quorum.blast_tmp_dir} -b #{Quorum.blast_db} " <<
          "-t #{Quorum.blast_threads} "
      else
        return cmd
      end

      cmd << "-s #{algo} -i #{id} " <<
        "-d #{ActiveRecord::Base.configurations[::Rails.env.to_s]['database']} " <<
        "-a #{ActiveRecord::Base.configurations[::Rails.env.to_s]['adapter']} " <<
        "-k #{ActiveRecord::Base.configurations[::Rails.env.to_s]['host']} " <<
        "-u #{ActiveRecord::Base.configurations[::Rails.env.to_s]['username']} " <<
        "-p '#{ActiveRecord::Base.configurations[::Rails.env.to_s]['password']}' "
    end

  end
end
