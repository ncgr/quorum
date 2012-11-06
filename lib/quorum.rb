require "quorum/engine"
require "quorum/helpers"
require "quorum/sequence"
require "quorum/version"
require "resque"
require "resque/server"
require "resque-result"
require "net/ssh"
require "workers/system"

module Quorum

  ## Supported Algorithms ##
  BLAST_ALGORITHMS = [
    "blastn", "blastx", "blastp", "tblastn", "tblastx"
  ].freeze

  mattr_accessor :max_sequence_size, :blast_remote, :blast_ssh_host,
                 :blast_ssh_user, :blast_ssh_options, :blast_bin,
                 :blast_log_dir, :blast_tmp_dir, :blast_db, :tblastn,
                 :blastp, :blastn, :blastx, :tblastx, :blast_threads

  ## Deprecated ##
  mattr_accessor :blast_script

  class << self

    ## General ##

    # Max input sequence size.
    def max_sequence_size
      @@max_sequence_size || 50.kilobytes
    end

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

    # Blast bin path.
    def blast_bin
      @@blast_bin || nil
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

    # tblastx directories.
    def tblastx
      @@tblastx || []
    end

    # Number of Blast threads.
    def blast_threads
      @@blast_threads || 1
    end

    ## Blast Deprecated ##

    def blast_script
      nil
    end

  end

end
