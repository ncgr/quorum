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
        "> #{@fasta} 2> /dev/null"
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
      # Discover input sequence type (nucleic acid NA or amino acid AA).
      #
      # Subtracting all AA single letter chars from NA single letter chars
      # (including ALL ambiguity codes for each!) leaves us with
      # EQILFP. If a sequence contains EQILFP, it's safe to call it an AA. 
      #
      # See single letter char tables for more information:
      # http://en.wikipedia.org/wiki/Proteinogenic_amino_acid
      # http://www.chick.manchester.ac.uk/SiteSeer/IUPAC_codes.html
      #
      # If a sequence doesn't contain EQILFP, it could be either an AA 
      # or NA. To distinguish the two, count the number of As Ts Gs Cs
      # and Ns, divide by the the length of the sequence and * 100.
      #
      # If the percentage of A, T, G, C or N is >= 15.0, call it a NA.
      # 15% was choosen based on the data in the table 
      # "Relative proportions (%) of bases in DNA" 
      # (http://en.wikipedia.org/wiki/Chargaff's_rules) and the
      # precentage of AAs found in peptides
      # (http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2590925/).
      #
      def discover_input_sequence_type
        file  = File.open(@fasta)

        # If we make this far, we know the sequences are in FASTA format.
        seqs  = file.read.split('>')
        seqs.delete_if { |l| l.empty? }

        stats    = [] # Holds the sequence call. 1 = AA, 0 = NA.
        num_seqs = seqs.length.to_f

        seqs.each do |s|
          # Index of the first newline char.
          start = s.index(/\n/)
          # Remove the sequence FASTA header.
          seq   = s.slice(start..-1).gsub!(/\n/, '')

          if seq =~ /[EQILFP]+/
            stats << 1
          else
            # Length of the sequence minus the FASTA header.
            len = seq.length.to_f

            na_percent = 15.0

            a = (seq.count("A").to_f / len) * 100
            t = (seq.count("T").to_f / len) * 100

            g = (seq.count("G").to_f / len) * 100
            c = (seq.count("C").to_f / len) * 100

            n = (seq.count("N").to_f / len) * 100
            
            if (a >= na_percent) || (c >= na_percent) || (t >= na_percent) || 
              (g >= na_percent) || (n >= na_percent)
              stats << 0
            else
              stats << 1
            end
          end
        end

        # Sum the values in the array.
        sum = stats.inject(0) { |s, v| s + v }
        logger(
          "Stats used to call AA or NA sequence(s).",
          "(#{sum.to_f.to_s} / #{num_seqs.to_s}) = " << 
          "#{(sum.to_f / num_seqs).to_s}\n" <<
          "0.0...0.5 ==> NA\n0.5...1.0 ==> AA"
        )

        # Divide the sum by the number of input sequences. If the value
        # is > 0.5, call it an AA. If the value is < 0.5, call it a NA.
        begin
          if ((sum.to_f / num_seqs)  > 0.5)
            @type = "amino_acid"
          else
            @type = "nucleic_acid"
          end
        rescue ZeroDivisionError => e
          logger(
            "discover_input_sequence_type",
            "Can not divide by zero",
            1
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
        begin
          @blast = QuorumBlast.find(@id)
        rescue Exception => e
          logger("ActiveRecord", e.message, 80)
        end
        @sequence       = @blast.sequence
        @min_bit_score  = @blast.min_bit_score

        create_unique_hash

        write_input_sequence_to_file

        discover_input_sequence_type

        generate_blast_cmd 

        logger("NCBI Blast", @cmd)

        # Execute each system command in a Thread.
        threads = []
        @cmd.each do |c|
          threads << Thread.new { system(c) }
        end
        # Wait for every Thread to finish working.
        threads.each { |t| t.join }

        parse_and_save_results
      end

    end
  end
end
