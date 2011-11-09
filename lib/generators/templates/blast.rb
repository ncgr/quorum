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

        @sequence = @job.na_sequence

        @tblastn = @blastp = @blastn = @blastx = nil

        case @algorithm
        when "blastn"
          begin
            @blastn_job = QuorumBlastnJob.find(@id)
          rescue Exception => e
            @logger.log("ActiveRecord", e.message, 80)
          end

          @expectation           = @blastn_job.expectation
          @max_score             = @blastn_job.max_score
          @min_score             = @blastn_job.min_bit_score
          @gapped_alignments     = @blastn_job.gapped_alignments
          @gap_opening_penalty   = @blastn_job.gap_opening_penalty
          @gap_extension_penalty = @blastn_job.gap_extension_penalty

          @blastn = @blastn_job.blast_dbs.split(';')
          @blastn.map! { |d| File.join(@search_database, d) }
          @blastn = @blastn.join(' ')
        when "blastx"
          begin
            @blastx_job = QuorumBlastxJob.find(@id)
          rescue Exception => e
            @logger.log("ActiveRecord", e.message, 80)
          end

          @expectation           = @blastx_job.expectation
          @max_score             = @blastx_job.max_score
          @min_score             = @blastx_job.min_bit_score
          @gapped_alignments     = @blastx_job.gapped_alignments
          @gap_opening_penalty   = @blastx_job.gap_opening_penalty
          @gap_extension_penalty = @blastx_job.gap_extension_penalty

          @blastx = @blastx_job.blast_dbs.split(';')
          @blastx.map! { |d| File.join(@search_database, d) }
          @blastx = @blastx.join(' ')
        when "tblastn"
          begin
            @tblastn_job = QuorumTblastnJob.find(@id)
          rescue Exception => e
            @logger.log("ActiveRecord", e.message, 80)
          end

          @expectation           = @tblastn_job.expectation
          @max_score             = @tblastn_job.max_score
          @min_score             = @tblastn_job.min_bit_score
          @gapped_alignments     = @tblastn_job.gapped_alignments
          @gap_opening_penalty   = @tblastn_job.gap_opening_penalty
          @gap_extension_penalty = @tblastn_job.gap_extension_penalty

          @tblastn = @tblastn_job.blast_dbs.split(';')
          @tblastn.map! { |d| File.join(@search_database, d) }
          @tblastn = @tblastn.join(' ')
        when "blastp"
          begin
            @blastp_job = QuorumBlastpJob.find(@id)
          rescue Exception => e
            @logger.log("ActiveRecord", e.message, 80)
          end

          @expectation           = @blastp_job.expectation
          @max_score             = @blastp_job.max_score
          @min_score             = @blastp_job.min_bit_score
          @gapped_alignments     = @blastp_job.gapped_alignments
          @gap_opening_penalty   = @blastp_job.gap_opening_penalty
          @gap_extension_penalty = @blastp_job.gap_extension_penalty

          @blastp = @blastp_job.blast_dbs.split(';')
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
        
        @out = File.join(@tmp, @hash + ".out.xml") 

        File.new(@out, "w")
        File.new(@out, "w")

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
            "-out #{@out} "
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
            "-out #{@out} "
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
            "-out #{@out} "
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
            "-out #{@out} "
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
        
        report = Bio::Blast::XmlIterator.new(@out)
        report.to_enum.each do |iteration|

          case @algorithm
          when "blastn"
            @report = QuorumBlastnJobReport.new
          when "blastx"
            @report = QuorumBlastxJobReport.new
          when "tblastn"
            @report = QuorumTblastnJobReport.new
          when "blastp"
            @report = QuorumBlastpJobReport.new
          end

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
            @report.blastn_job_id = @blastn_job.id
          when "blastx"
            @report.blastx_job_id = @blastx_job.id
          when "tblastn"
            @report.tblastn_job_id = @tblastn_job.id
          when "blastp"
            @report.blastp_job_id = @blastp_job.id
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
