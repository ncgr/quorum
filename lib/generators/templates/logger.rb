module Quorum
  class Logger

    def initialize(dir)
      @log_directory = dir
      @log_file      = "quorum.log"
    end

    #
    # Write to log file and exit if exit_status is present.
    #
    def log(program, message, exit_status = nil, files = nil)
      File.open(File.join(@log_directory, @log_file), "a") do |log|
        log.puts ""
        log.puts Time.now.to_s + " " + program
        log.puts message
        log.puts ""
      end

      if exit_status
        remove_files(files) unless files.nil?
        exit exit_status.to_i
      end
    end

    private

    #
    # Removes instance files.
    #
    def remove_files(files)
      if Dir.glob(files).empty?
         log(
          "remove_files",
          "Unable to remove #{files}"
        )
      else
       `rm #{files}`
      end
    end

  end
end
