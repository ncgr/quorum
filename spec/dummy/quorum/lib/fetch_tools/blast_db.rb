$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))

require 'logger'

module Quorum
  module FetchTools
    #
    # Blast DB Fetch Tool
    #
    class BlastDb

      # blastdbcmd -dbtype
      DB_TYPE = {
        "blastn"  => "nucl",
        "blastx"  => "prot",
        "tblastn" => "nucl",
        "blastp"  => "prot"
      }

      private

      def initialize(args)
        @tool           = args[:fetch_tool]
        @entry          = args[:blast_hit_id]
        @hit_display_id = args[:blast_hit_display_id]
        @blast_algo     = args[:blast_algo]
        @log_directory  = args[:log_directory]
        @tmp_directory  = args[:tmp_directory]
        @fetch_database = args[:fetch_database]
        @databases      = args[:fetch_database_names]

        @logger = Quorum::Logger.new(@log_directory)

        @db = @databases.split(';')
        @db.map! { |d| File.join(@fetch_database, d) }

        @db_type = DB_TYPE[@blast_algo]
        @db_type ||= 'guess'
      end

      #
      # Generate the blastdbcmd(s).
      #
      def generate_blast_db_cmds
        @cmds = []
        @db.each do |d|
          blastdbcmd = "blastdbcmd " <<
          "-db '#{d}' " <<
          "-dbtype '#{@db_type}' " <<
          "-entry '#{@entry}' "
          @cmds << blastdbcmd
        end
      end

      #
      # Parse the blastdbcmd returned sequence(s) and delete if @hit_display_id
      # is not present.
      #
      def parse_and_send_results
        seqs = @seqs.split('>')
        seqs.delete_if { |s| s.empty? || !s.include?(@hit_display_id) }
        if seqs.length != 1
          @logger.log(
            "Quorum::FetchTools::BlastDb#parse_and_send_results",
            "blastdbcmd returned #{seqs.length} sequence(s). Please ensure " <<
            "your Blast database source FASTA headers are unique across ALL " <<
            "databases. See the entry above for details."
          )
          "An error occurred while processing your request."
        else
          ">" << seqs.first
        end
      end

      public

      #
      # Execute the blastdbcmd(s) and return the matching sequence.
      #
      # To make Blast execute as quickly as possible, each selected 
      # algorithm blasts against all supplied databases at once. 
      # 
      # See quorum/lib/search_tools/blast.rb for more information. 
      #
      # One consequence of this is not knowing which Blast database to use
      # when retrieving a hit sequence via blastdbcmd.
      #
      # See blastdbcmd -help for more information.
      #
      # To work around this issue, simply execute blastdbcmd against all
      # Blast databases and filter on hit_display_id.
      #
      def execute_blast_db_cmd
        generate_blast_db_cmds
        @logger.log("NCBI Blast", @cmds.join('; '))
        
        @seqs = ""
        @cmds.each { |c| @seqs << `#{c} 2> /dev/null` }
        
        seq = parse_and_send_results
        $stdout.print seq
      end

    end
  end
end
