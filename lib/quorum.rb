require "quorum/engine"
require "quorum/helpers"
require "quorum/sequence"
require "workers/quorum"
require "resque"
require "resque/server"
require "net/ssh"

module Quorum

  ## Supported Algorithms ##
  BLAST_ALGORITHMS = ["blastn", "blastx", "blastp", "tblastn"]
  HMMER_ALGORITHMS = ["hmmscan"]

  mattr_accessor :blast_remote, :blast_ssh_host, :blast_ssh_user, 
    :blast_ssh_options, :blast_script, :blast_log_dir, :blast_tmp_dir,
    :blast_db, :tblastn, :blastp, :blastn, :blastx, :blast_threads,
    :hmmer_remote, :hmmer_ssh_host, :hmmer_ssh_user, :hmmer_ssh_options, 
    :hmmer_script, :hmmer_log_dir, :hmmer_tmp_dir, :hmmer_db, :hmmer_threads

  class << self

    ## Blast ##

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

    ## Hmmer ##

    # Execute remotely.
    def hmmer_remote
      @@hmmer_remote || false
    end

    # Net::SSH host.
    def hmmer_ssh_host
      @@hmmer_ssh_host || nil
    end

    # Net::SSH user.
    def hmmer_ssh_user
      @@hmmer_ssh_user || nil
    end

    # Net::SSH options.
    def hmmer_ssh_options
      @@hmmer_ssh_options || {}
    end

    # Hmmer script path.
    def hmmer_script
      @@hmmer_script || nil
    end

    # Hmmer log dir path.
    def hmmer_log_dir
      @@hmmer_log_dir || nil
    end

    # Hmmer tmp dir path.
    def hmmer_tmp_dir
      @@hmmer_tmp_dir || nil
    end

    # Hmmer database path.
    def hmmer_db
      @@hmmer_db || nil
    end

    # Number of Hmmer threads.
    def hmmer_threads
      @@hmmer_threads || 2
    end

  end

end
