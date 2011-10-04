module Quorum
  #
  # Blast Search Tool
  #
  class ExecuteBlast < ActiveRecord::Base
    
    set_table_name "quorum_blasts"

    BLASTN_OUTFMT  = %w[
      qseqid qlen sseqid slen qstart qend sstart send
      qseq sseq evalue bitscore score length pident nident
      mismatch positive gapopen gaps ppos frames qframe sframe
    ]
    BLASTX_OUTFMT  = %w[
    
    ]
    TBLASTN_OUTFMT = %w[
    
    ]
    BLASTP_OUTFMT  = %w[
    
    ]

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
        @blast = ExecuteBlast.find(@id)
      rescue Exception => e
        logger("ActiveRecord", e.message, 80)
      end

      @type     = @blast.sequence_type
      @sequence = @blast.sequence
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
      @cmd = ""

      @rep  = File.join(@tmp, @hash + ".rep") 
      @prot = File.join(@tmp, @hash + ".prot")

      File.new(@rep, "w")
      File.new(@prot, "w")

      if @type == "nucleic_acid"
        if @blastn
          blastn = "blastn " <<
            "-db #{@blastn} " <<
            "-query #{@fasta} " <<
            "-outfmt \"6 #{BLASTN_OUTFMT.join(' ')}\" " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@rep} "
          if @blast_gapped_alignments
            blastn << "-gapopen #{@blast_gap_opening_penalty} "
            blastn << "-gapextend #{@blast_gap_extension_penalty} "
          else
            blastn << "-ungapped "
          end
          blastn << "& " if @blastx
          @cmd << blastn
        end
        if @blastx
          blastx = "blastx " <<
            "-db #{@blastx} " <<
            "-query #{@fasta} " <<
            "-outfmt \"6 #{BLASTX_OUTFMT.join(' ')}\" " <<
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
            "-outfmt \"6 #{TBLASTN_OUTFMT.join(' ')}\" " <<
            "-num_threads #{@blast_threads} " <<
            "-evalue #{@blast_expectation} " <<
            "-max_target_seqs #{@blast_max_score} " <<
            "-out #{@rep} "
          if @blast_gapped_alignments
            tblastn << "-gapopen #{@blast_gap_opening_penalty} "
            tblastn << "-gapextend #{@blast_gap_extension_penalty} "
            tblastn << "-comp_based_stats D "
          else
            tblastn << "-ungapped "
            tblastn << "-comp_based_stats F "
          end
          tblastn << "& " if @blastp
          @cmd << tblastn
        end
        if @blastp
          blastp = "blastp " <<
            "-db #{@blastp} " <<
            "-query #{@fasta} " <<
            "-outfmt \"6 #{BLASTP_OUTFMT.join(' ')}\" " <<
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
          end
          @cmd << blastp
        end
      end
    end

    #
    # Execute Blast on a given dataset.
    #
    def blast
      find_blast_data

      create_unique_hash

      write_input_sequence_to_file

      generate_blast_cmd 

      logger("NCBI Blast", @cmd)

      system(@cmd)

      system("cat #{@prot} >> #{@rep}")

      file = File.open(@rep, "r")

      if file.size == 0
        logger(
          "NCBI Blast", 
          "Blast report empty.", 
          71
        )
      else
        @blast.results = file.read
        if @blast.save
          remove_files
        else
          logger(
            "ActiveRecord",
            "Unable to save Blast results to database.",
            81
          )
        end
      end
    end

  end
end
