$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bio-blastxmlparser'
require 'logger'

module Quorum
  module SearchTools
    #
    # Blast Search Tool
    #
    class Blast

      class QuorumJob < ActiveRecord::Base; end

      class QuorumBlastnJob < ActiveRecord::Base; end
      class QuorumBlastnJobReport < ActiveRecord::Base; end

      class QuorumBlastxJob < ActiveRecord::Base; end
      class QuorumBlastxJobReport < ActiveRecord::Base; end

      class QuorumTblastnJob < ActiveRecord::Base; end
      class QuorumTblastnJobReport < ActiveRecord::Base; end

      class QuorumBlastpJob < ActiveRecord::Base; end
      class QuorumBlastpJobReport < ActiveRecord::Base; end

      private

      def initialize(args)
        @algorithm       = args[:search_tool]
        @id              = args[:id]
        @log_directory   = args[:log_directory]
        @tmp             = args[:tmp_directory]
        @search_database = args[:search_database]
        @threads         = args[:threads]

        @logger = Quorum::Utils::Logger.new(@log_directory)

        begin
          @job = QuorumJob.find(@id)
        rescue Exception => e
          @logger.log("ActiveRecord", e.message, 80)
        end

        @tblastn = @blastp = @blastn = @blastx = nil

        case @algorithm
        when "blastn"
          @sequence              = @job.na_sequence
          @expectation           = @job.blastn_job.expectation
          @max_score             = @job.blastn_job_max_score
          @min_score             = @job.blastn_job_min_bit_score
          @gapped_alignments     = @job.blastn_job_gapped_alignments
          @gap_opening_penalty   = @job.blastn_job_gap_opening_penalty
          @gap_extension_penalty = @job.blastn_job_gap_extension_penalty

          @blastn = @job.blastn_job.blast_dbs.split(';')
          @blastn.map! { |d| File.join(@search_database, d) }
          @blastn = @blastn.join(' ')
        when "blastx"
          @sequence              = @job.na_sequence
          @expectation           = @job.blastx_job.expectation
          @max_score             = @job.blastx_job_max_score
          @min_score             = @job.blastx_job_min_bit_score
          @gapped_alignments     = @job.blastx_job_gapped_alignments
          @gap_opening_penalty   = @job.blastx_job_gap_opening_penalty
          @gap_extension_penalty = @job.blastx_job_gap_extension_penalty

          @blastx = @job.blastx_job.blast_dbs.split(';')
          @blastx.map! { |d| File.join(@search_database, d) }
          @blastx = @blastx.join(' ')
        when "tblastn"
          @sequence              = @job.aa_sequence
          @expectation           = @job.tblastn_job.expectation
          @max_score             = @job.tblastn_job_max_score
          @min_score             = @job.tblastn_job_min_bit_score
          @gapped_alignments     = @job.tblastn_job_gapped_alignments
          @gap_opening_penalty   = @job.tblastn_job_gap_opening_penalty
          @gap_extension_penalty = @job.tblastn_job_gap_extension_penalty

          @tblastn = @job.tblastn_job.blast_dbs.split(';')
          @tblastn.map! { |d| File.join(@search_database, d) }
          @tblastn = @tblastn.join(' ')
        when "blastp"
          @sequence              = @job.aa_sequence
          @expectation           = @job.blastp_job.expectation
          @max_score             = @job.blastp_job_max_score
          @min_score             = @job.blastp_job_min_bit_score
          @gapped_alignments     = @job.blastp_job_gapped_alignments
          @gap_opening_penalty   = @job.blastp_job_gap_opening_penalty
          @gap_extension_penalty = @job.blastp_job_gap_extension_penalty

          @blastp = @job.blastp_job.blast_dbs.split(';')
          @blastp.map! { |d| File.join(@search_database, d) }
          @blastp = @blastp.join(' ')
        end

        @hash      = @job.sequence_hash
        @tmp_files = File.join(@tmp, @hash) << "*"
      end

      #
      # Generate Blast Command
      #
      def generate_blast_cmd
        @cmd = ""

        @fasta = File.join(@tmp, @hash + ".fa")
        File.open(@fasta, "w") { |f| f << @sequence }
        
        @nucl = File.join(@tmp, @hash + ".nucl.xml") 
        @prot = File.join(@tmp, @hash + ".prot.xml")

        File.new(@nucl, "w")
        File.new(@prot, "w")

        case @algorithm
        when "blastn"
          if @blastn
            blastn = "blastn " <<
            "-db #{@blastn} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@threads} " <<
            "-evalue #{@expectation} " <<
            "-max_target_seqs #{@max_score} " <<
            "-out #{@nucl} "
            if @gapped_alignments
              blastn << "-gapopen #{@gap_opening_penalty} "
              blastn << "-gapextend #{@gap_extension_penalty} "
            else
              blastn << "-ungapped "
            end
            @cmd << blastn
          end
        when "blastx"
          if @blastx
            blastx = "blastx " <<
            "-db #{@blastx} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@threads} " <<
            "-evalue #{@expectation} " <<
            "-max_target_seqs #{@max_score} " <<
            "-out #{@prot} "
            if @gapped_alignments
              blastx << "-gapopen #{@gap_opening_penalty} "
              blastx << "-gapextend #{@gap_extension_penalty} "
            else
              blastx << "-ungapped "
            end
            @cmd << blastx
          end
        when "tblastn"
          if @tblastn
            tblastn = "tblastn " <<
            "-db #{@tblastn} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@threads} " <<
            "-evalue #{@expectation} " <<
            "-max_target_seqs #{@max_score} " <<
            "-out #{@nucl} "
            if @gapped_alignments
              tblastn << "-gapopen #{@gap_opening_penalty} "
              tblastn << "-gapextend #{@gap_extension_penalty} "
              tblastn << "-comp_based_stats D "
            else
              tblastn << "-ungapped "
              tblastn << "-comp_based_stats F "
            end
            @cmd << tblastn
          end
        when "blastp"
          if @blastp
            blastp = "blastp " <<
            "-db #{@blastp} " <<
            "-query #{@fasta} " <<
            "-outfmt 5 " <<
            "-num_threads #{@threads} " <<
            "-evalue #{@expectation} " <<
            "-max_target_seqs #{@max_score} " <<
            "-out #{@prot} "
            if @gapped_alignments
              blastp << "-gapopen #{@gap_opening_penalty} "
              blastp << "-gapextend #{@gap_extension_penalty} "
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
      # Only save Blast results if results.bit_score > @min_score. 
      #
      def parse_and_save_results
        # Helper to avoid having to perform a query.
        saved = false
        
        [@prot, @nucl].each do |f|
          report = Bio::Blast::XmlIterator.new(f)
          report.to_enum.each do |iteration|
            const   = "Quorum#{@algorithm.capitalize}JobReport"
            @report = const.constantize.new

            @report.query     = iteration.query_def
            @report.query_len = iteration.query_len

            iteration.each do |hit|
              @report.hit_id        = hit.hit_id            
              @report.hit_def       = hit.hit_def
              @report.hit_accession = hit.accession
              @report.hit_len       = hit.len

              hit.each do |hsp|
                @report.bit_score   = hsp.bit_score
                @report.score       = hsp.score
                @report.evalue      = hsp.evalue
                @report.query_from  = hsp.query_from
                @report.query_to    = hsp.query_to
                @report.hit_from    = hsp.hit_from
                @report.hit_to      = hsp.hit_to
                @report.query_frame = hsp.query_frame
                @report.hit_frame   = hsp.hit_frame
                @report.identity    = hsp.identity
                @report.positive    = hsp.positive
                @report.align_len   = hsp.align_len
                @report.qseq        = hsp.qseq
                @report.hseq        = hsp.hseq
                @report.midline     = hsp.midline
              end
            end

            case @algorithm
            when "blastn"
              @report.blastn_job_id = @job.blastn_job.id
            when "blastx"
              @report.blastx_job_id = @job.blastx_job.id
            when "tblastn"
              @report.tblastn_job_id = @job.tblastn_job.id
            when "blastp"
              @report.blastp_job_id = @job.blastp_job.id
            end

            # Hsps are only reported if a query hit against the Blast db.
            # Only save the @report if bit_score exists.
            if @report.bit_score && 
              (@report.bit_score.to_i > @min_score.to_i)
              saved = true
              unless @report.save!
                @logger.log(
                  "ActiveRecord",
                  "Unable to save Blast results to database.",
                  81,
                  @tmp_files
                )
              end
            end
          end 
        end

        unless saved
          @logger.log(
            "Blast",
            "Blast Report empty.",
            71,
            @tmp_files
          )
        end
      end

      def remove_tmp_files
        `rm #{@tmp_files}` if @tmp_files
      end

      public

      #
      # Execute Blast on a given dataset.
      #
      def execute_blast
        generate_blast_cmd 
        @logger.log("NCBI Blast", @cmd)
        system(@cmd)
        parse_and_save_results
        remove_tmp_files
      end

    end
  end
end
