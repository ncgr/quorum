require 'bio-blastxmlparser'

module Quorum
  module Tools
    #
    # Blast Search Tool
    #
    class Blast
      class QuorumBlast < ActiveRecord::Base; end
      class QuorumBlastReport < ActiveRecord::Base; end

      def initialize(args)
        @id             = args[:id]
        @log_directory  = args[:log_directory]
        @tmp            = args[:tmp_directory]
        @blast_database = args[:blast_database]
        @blast_threads  = args[:blast_threads]

        @tblastn = @blastp = @blastn = @blastx = nil

        # Format Blast databases.
        if args[:tblastn]
          @tblastn = args[:tblastn].split(';')
          @tblastn.map! { |d| File.join(@blast_database, d) }
          @tblastn = @tblastn.join(' ')
        end
        if args[:blastp]
          @blastp = args[:blastp].split(';')
          @blastp.map! { |d| File.join(@blast_database, d) }
          @blastp = @blastp.join(' ')
        end
        if args[:blastn]
          @blastn = args[:blastn].split(';')
          @blastn.map! { |d| File.join(@blast_database, d) }
          @blastn = @blastn.join(' ')
        end
        if args[:blastx]
          @blastx = args[:blastx].split(';')
          @blastx.map! { |d| File.join(@blast_database, d) }
          @blastx = @blastx.join(' ')
        end

        # Optional params.
        @blast_expectation           = args[:expectation] || "5e-20"
        @blast_max_score             = args[:max_score] || 25
        @blast_min_bit_score         = args[:min_bit_score] || 0
        @blast_gapped_alignments     = args[:gapped_alignments] || false
        @blast_gap_opening_penalty   = args[:gap_opening_penalty] || 0
        @blast_gap_extension_penalty = args[:gap_extension_penalty] || 0
      end

      #
      # Removes instance files in @tmp prefixed with @hash.
      #
      def remove_files
        `rm #{File.join(@tmp, @hash)}*` if @hash
      end

      #
      # Write to log file and exit if exit_status is present.
      #
      def logger(program, message, exit_status = nil)
        File.open(File.join(@log_directory, "blast.log"), "a") do |log|
          log.puts ""
          log.puts Time.now.to_s + " " + program
          log.puts message
          log.puts ""
        end

        if exit_status
          remove_files
          exit exit_status.to_i
        end
      end

      #
      # Create a unique hash based on @blast.sequence.
      #
      def create_unique_hash
        @hash = Digest::MD5.hexdigest(@sequence).to_s + "-" + 
          Time.now.to_i.to_s
      end

      #
      # Retrive data from db.
      #
      def find_blast_data
        begin
          @blast = QuorumBlast.find(@id)
        rescue Exception => e
          logger("ActiveRecord", e.message, 80)
        end

        @type           = @blast.sequence_type
        @sequence       = @blast.sequence
        @min_bit_score  = @blast.min_bit_score
      end

      #
      # Write input sequence to file.
      #
      def write_input_sequence_to_file
        seq = File.join(@tmp, @hash + ".seq") 
        File.open(seq, "w") do |f|
          f << @sequence
        end

        @fasta = File.join(@tmp, @hash + ".fa")

        # Force FASTA format.
        cmd = "seqret -filter -sformat pearson -osformat fasta < #{seq} " <<
        "> #{@fasta}"
        system(cmd)
        if $?.exitstatus > 0
          logger(
            "seqret", 
            "Input sequence not in FASTA format.",
            70
          )
        end
      end

      #
      # Generate Blast Command
      #
      def generate_blast_cmd
        @cmd = []

        @nucl = File.join(@tmp, @hash + ".nucl.xml") 
        @prot = File.join(@tmp, @hash + ".prot.xml")

        File.new(@nucl, "w")
        File.new(@prot, "w")

        if @type == "nucleic_acid"
          if @blastn
            blastn = "blastn " <<
            "-db #{@blastn} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@nucl} "
            if @blast_gapped_alignments
              blastn << "-gapopen #{@blast_gap_opening_penalty} "
              blastn << "-gapextend #{@blast_gap_extension_penalty} "
            else
              blastn << "-ungapped "
            end
            @cmd << blastn
          end
          if @blastx
            blastx = "blastx " <<
            "-db #{@blastx} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@prot} "
            if @blast_gapped_alignments
              blastx << "-gapopen #{@blast_gap_opening_penalty} "
              blastx << "-gapextend #{@blast_gap_extension_penalty} "
            else
              blastx << "-ungapped "
            end
            @cmd << blastx
          end
        end

        if @type == "amino_acid"
          if @tblastn
            tblastn = "tblastn " <<
            "-db #{@tblastn} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@nucl} "
            if @blast_gapped_alignments
              tblastn << "-gapopen #{@blast_gap_opening_penalty} "
              tblastn << "-gapextend #{@blast_gap_extension_penalty} "
              tblastn << "-comp_based_stats D "
            else
              tblastn << "-ungapped "
              tblastn << "-comp_based_stats F "
            end
            @cmd << tblastn
          end
          if @blastp
            blastp = "blastp " <<
            "-db #{@blastp} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@prot} "
            if @blast_gapped_alignments
              blastp << "-gapopen #{@blast_gap_opening_penalty} "
              blastp << "-gapextend #{@blast_gap_extension_penalty} "
              blastp << "-comp_based_stats D "
            else
              blastp << "-ungapped "
              blastp << "-comp_based_stats F "
              blastp << "-seg yes "
            end
            @cmd << blastp
          end
        end
      end

      #
      # Parse and save Blast results using bio-blastxmlparser.
      # Only save Blast results if results.bit_score > @min_bit_score. 
      #
      def parse_and_save_results
        
        # Helper to avoid having to perform a query.
        saved = false
        
        [@prot, @nucl].each do |f|
          report = Bio::Blast::XmlIterator.new(f)
          report.to_enum.each do |iteration|
            @blast_report = QuorumBlastReport.new

            @blast_report.query     = iteration.query_def
            @blast_report.query_len = iteration.query_len

            iteration.each do |hit|
              @blast_report.hit_id        = hit.hit_id            
              @blast_report.hit_def       = hit.hit_def
              @blast_report.hit_accession = hit.accession
              @blast_report.hit_len       = hit.len

              hit.each do |hsp|
                @blast_report.bit_score   = hsp.bit_score
                @blast_report.score       = hsp.score
                @blast_report.evalue      = hsp.evalue
                @blast_report.query_from  = hsp.query_from
                @blast_report.query_to    = hsp.query_to
                @blast_report.hit_from    = hsp.hit_from
                @blast_report.hit_to      = hsp.hit_to
                @blast_report.query_frame = hsp.query_frame
                @blast_report.hit_frame   = hsp.hit_frame
                @blast_report.identity    = hsp.identity
                @blast_report.positive    = hsp.positive
                @blast_report.align_len   = hsp.align_len
                @blast_report.qseq        = hsp.qseq
                @blast_report.hseq        = hsp.hseq
                @blast_report.midline     = hsp.midline
              end
            end
            @blast_report.blast_id = @blast.id

            # Hsps are only reported if a query hit against the Blast db.
            # Only save the @blast_report if bit_score exists.
            if @blast_report.bit_score && 
              (@blast_report.bit_score.to_i > @min_bit_score.to_i)
              saved = true
              unless @blast_report.save!
                logger(
                  "ActiveRecord",
                  "Unable to save Blast results to database.",
                  81
                )
              end
            end
          end 
        end

        unless saved
          logger(
            "Blast",
            "Blast Report empty.",
            71
          )
        end
        remove_files
      end

      #
      # Execute Blast on a given dataset.
      #
      def execute_blast
        find_blast_data

        create_unique_hash

        write_input_sequence_to_file

        generate_blast_cmd 

        logger("NCBI Blast", @cmd)

        @cmd.each { |c| system(c) }

        parse_and_save_results
      end

    end
  end
end
