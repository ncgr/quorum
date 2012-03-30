module Workers
  class System
    extend Resque::Plugins::Result

    @queue = :system_queue

    #
    # Resque worker method.
    #
    def self.perform(meta_id, cmd, remote, ssh_host, ssh_user, ssh_options = {}, stdout = false)
      unless ssh_options.empty?
        # Convert each key in ssh_options to a symbol.
        ssh_options = ssh_options.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
        memo
        end
      end

      exit_status = 1
      out         = ""

      if remote
        # Execute command on remote machine.
        Net::SSH.start(ssh_host, ssh_user, ssh_options) do |ssh|
          ssh.open_channel do |ch|
            ch.exec(cmd) do |ch, success|
              unless success
                Rails.logger.warn "Channel Net::SSH exec() failed. :'("
              else
                # Capture STDOUT from ch.exec()
                if stdout
                  ch.on_data do |ch, data|
                    out = data
                  end
                end
                # Read the exit status of the remote process.
                ch.on_request("exit-status") do |ch, data|
                  exit_status = data.read_long
                end
              end
            end
          end
          ssh.loop
        end
      else
        out         = `#{cmd}`
        exit_status = $?.exitstatus
      end
      if exit_status > 0
        raise "Worker failed :'(. See quorum/log/quorum.log for more information."
      end
      out if stdout
    end
  end
end
