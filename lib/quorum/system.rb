module Quorum
  module System
    
    #
    # Execute system command.
    #
    def execute_cmd(cmd, remote, ssh_host, ssh_user, ssh_options = {})
      Rails.logger.debug "\n-- quorum command --\n" + cmd + "\n\n"

      unless ssh_options.empty?
        # Convert each key in ssh_options to a symbol.
        ssh_options = ssh_options.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
          memo
        end
      end

      exit_status = 1

      if remote
        # Execute command on remote machine.
        Net::SSH.start(ssh_host, ssh_user, ssh_options) do |ssh|
          ssh.open_channel do |ch|
            ch.exec(cmd) do |ch, success|
              unless success 
                Rails.logger.warn "Channel Net::SSH exec() failed. :'("
              else
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
        system(cmd)
        exit_status = $?.exitstatus
      end
      status = "error_" << exit_status.to_s
      status.to_sym
    end

  end
end
