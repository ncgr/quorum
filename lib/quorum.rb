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
  BLAST_ALGORITHMS     = ["blastn", "blastx", "blastp", "tblastn"].freeze
  GMAP                 = ["gmap"].freeze
  SUPPORTED_ALGORITHMS = [BLAST_ALGORITHMS, GMAP]
  SUPPORTED_ALGORITHMS.flatten!

  mattr_accessor :max_sequence_size, :gmap_remote, :gmap_ssh_host,
                 :gmap_ssh_user, :gmap_ssh_options, :gmap_bin,
                 :gmap_log_dir, :gmap_tmp_dir, :gmap_db_dir, :gmap_db,
                 :gmap_max_internal_intron_len, :gmap_max_total_intron_len,
                 :gmap_threads, :blast_remote, :blast_ssh_host,
                 :blast_ssh_user, :blast_ssh_options, :blast_bin,
                 :blast_log_dir, :blast_tmp_dir, :blast_db, :tblastn,
                 :blastp, :blastn, :blastx, :blast_threads

  class << self

    ######################
    ## General Settings ##
    ######################

    # Max input sequence size.
    def max_sequence_size
      @@max_sequence_size || 50.kilobytes
    end

    ###################
    ## GMAP Settings ##
    ###################

    # Execute remotely.
    def gmap_remote
      @@gmap_remote || false
    end

    # Net::SSH host.
    def gmap_ssh_host
      @@gmap_ssh_host || nil
    end

    # Net::SSH user.
    def gmap_ssh_user
      @@gmap_ssh_user || nil
    end

    # Net::SSH options.
    def gmap_ssh_options
      @@gmap_ssh_options || {}
    end

    # Gmap bin path.
    def gmap_bin
      @@gmap_bin || nil
    end

    # Gmap log dir path.
    def gmap_log_dir
      @@gmap_log_dir || nil
    end

    # Gmap tmp dir path.
    def gmap_tmp_dir
      @@gmap_tmp_dir || nil
    end

    # Gmap database path.
    def gmap_db_dir
      @@gmap_db_dir || nil
    end

    # Gmap database path.
    def gmap_db
      @@gmap_db || []
    end

    # Gmap default max internal intron length.
    def gmap_max_internal_intron_len
      @@gmap_max_internal_intron_len || 1000000
    end

    # Gmap default max total intron length.
    def gmap_max_total_intron_len
      @@gmap_max_total_intron_len || 2400000
    end

    # Number of gmap threads.
    def gmap_threads
      @@gmap_threads || 1
    end

    ####################
    ## Blast Settings ##
    ####################

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

    # Number of Blast threads.
    def blast_threads
      @@blast_threads || 1
    end

  end

end
