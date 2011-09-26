module Quorum
  class ApplicationController < ActionController::Base

    private

    #
    # I18n flash helper. Set flash message based on key.
    #
    def set_flash_message(key, kind, options={})
      options[:scope] = "quorum.#{controller_name}"
      options[:scope] << ".errors" if key.to_s == "error"
      options[:scope] << ".notices" if key.to_s == "notice"
      options[:scope] << ".alerts" if key.to_s == "alert"
      message = I18n.t("#{kind}", options)
      flash[key] = message if message.present?
    end

    #
    # Execute system command.
    #
    def execute_cmd(cmd, remote, ssh_host, ssh_user, ssh_options = {})
      logger.debug "\n-- quorum command --\n" + cmd + "\n\n"

      if remote
        # Execute the script on the remote machine.
        Net::SSH.start(ssh_host, ssh_user, ssh_options) do |ssh|
          ssh.open_channel do |ch|
            ch.exec(cmd) do |ch, success|
              unless success 
                puts "Channel exec() failed. :("
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
      exit_status = "error_" + exit_status.to_s
      exit_status.to_sym
    end

  end
end
