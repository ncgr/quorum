require "quorum/engine"
require "quorum/system"
require "quorum/helpers"

module Quorum

  mattr_accessor :blast_remote, :blast_ssh_host, :blast_ssh_user, 
    :blast_ssh_options, :blast_script, :blast_log_dir, :blast_tmp_dir,
    :blast_db, :tblastn, :blastp, :blastn, :blastx, :blast_threads

  class << self
    # Execute remotely.
    def blast_remote
      @@blast_remote || false
    end

    # Net::SSH host.
    def blast_ssh_host
      @@blast_ssh_host || nil
    end

    # Net::SSH user.
    def blast_ssh_user
      @@blast_ssh_user || nil
    end

    # Net::SSH options.
    def blast_ssh_options
      @@blast_ssh_options || {}
    end

    # Blast script path.
    def blast_script
      @@blast_script || nil
    end

    # Blast log dir path.
    def blast_log_dir
      @@blast_log_dir || nil
    end

    # Blast tmp dir path.
    def blast_tmp_dir
      @@blast_tmp_dir || nil
    end

    # Blast database path.
    def blast_db
      @@blast_db || nil
    end

    # tblastn directories.
    def tblastn
      @@tblastn || []
    end

    # blastp directories.
    def blastp
      @@blastp || []
    end

    # blastn directories.
    def blastn
      @@blastn || []
    end

    # blastx directories.
    def blastx
      @@blastx || []
    end

    # Number of Blast threads.
    def blast_threads
      @@blast_threads || 1
    end
  end

end
