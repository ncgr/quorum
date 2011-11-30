$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bio-blastxmlparser'
require 'logger'

module Quorum
  module SearchTools
    #
    # Blast Search Tool
    #
    class Blast

      class QuorumJob < ActiveRecord::Base
        has_one :quorum_blastn_job, 
          :foreign_key => "job_id"
        has_many :quorum_blastn_job_reports, 
          :foreign_key => "blastn_job_id"

        has_one :quorum_blastx_job,
          :foreign_key => "job_id"
        has_many :quorum_blastx_job_reports,
          :foreign_key => "blastx_job_id"

        has_one :quorum_tblastn_job,
          :foreign_key => "job_id"
        has_many :quorum_tblastn_job_reports,
          :foreign_key => "tblastn_job_id"

        has_one :quorum_blastp_job,
          :foreign_key => "job_id"
        has_many :quorum_blastp_job_reports,
          :foreign_key => "blastp_job_id"
      end

      class QuorumBlastnJob < ActiveRecord::Base
        belongs_to :quorum_job
        has_many :quorum_blastn_job_reports
      end

      class QuorumBlastnJobReport < ActiveRecord::Base
        belongs_to :quorum_blastn_job
      end

      class QuorumBlastxJob < ActiveRecord::Base
        belongs_to :quorum_job
        has_many :quorum_blastx_job_reports
      end

      class QuorumBlastxJobReport < ActiveRecord::Base
        belongs_to :quorum_blastx_job
      end

      class QuorumTblastnJob < ActiveRecord::Base
        belongs_to :quorum_job
        has_many :quorum_tblastn_job_reports
      end

      class QuorumTblastnJobReport < ActiveRecord::Base
        belongs_to :quorum_tblastn_job
      end

      class QuorumBlastpJob < ActiveRecord::Base
        belongs_to :quorum_job
        has_many :quorum_blastp_job_reports
      end

      class QuorumBlastpJobReport < ActiveRecord::Base
        belongs_to :quorum_blastp_job
      end

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

        @na_sequence = @job.na_sequence
        @aa_sequence = @job.aa_sequence

        ## Create for method invocation ##
        @job_association        = "quorum_#{@algorithm}_job".to_sym
        @job_report_association = "quorum_#{@algorithm}_job_reports".to_sym

        @expectation           = @job.method(@job_association).call.expectation
        @max_score             = @job.method(@job_association).call.max_score
        @min_score             = @job.method(@job_association).call.min_bit_score
        @gapped_alignments     = @job.method(@job_association).call.gapped_alignments
        @gap_opening_penalty   = @job.method(@job_association).call.gap_opening_penalty
        @gap_extension_penalty = @job.method(@job_association).call.gap_extension_penalty

        @db = @job.method(@job_association).call.blast_dbs.split(';')
        @db.map! { |d| File.join(@search_database, d) }
        @db = @db.join(' ')

        @hash      = create_hash(@job.sequence)
        @tmp_files = File.join(@tmp, @hash) << "*"
      end

      #
      # Create a unique hash plus timestamp.
      #
      def create_hash(sequence)
        Digest::MD5.hexdigest(sequence).to_s + "-" + Time.now.to_f.to_s
      end

      #
      # Generate Blast Command
      #
      def generate_blast_cmd
        @cmd = ""

        @na_fasta = File.join(@tmp, @hash + ".na.fa")
        @aa_fasta = File.join(@tmp, @hash + ".aa.fa")
        File.open(@na_fasta, "w") { |f| f << @na_sequence }
        File.open(@aa_fasta, "w") { |f| f << @aa_sequence }
        
        @out = File.join(@tmp, @hash + ".out.xml") 

        File.new(@out, "w")
        File.new(@out, "w")

        case @algorithm
        when "blastn"
          blastn = "blastn " <<
          "-db \"#{@db}\" " <<
          "-query #{@na_fasta} " <<
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
        when "blastx"
          blastx = "blastx " <<
          "-db \"#{@db}\" " <<
          "-query #{@na_fasta} " <<
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
        when "tblastn"
          tblastn = "tblastn " <<
          "-db \"#{@db}\" " <<
          "-query #{@aa_fasta} " <<
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
        when "blastp"
          blastp = "blastp " <<
          "-db \"#{@db}\" " <<
          "-query #{@aa_fasta} " <<
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

      #
      # Make the E-value look pretty.
      #
      def format_evalue(evalue)
        evalue = evalue.to_s
        e      = evalue.slice!(/e.*/)
        unless e.nil?
          e = "e<sup>" << e.sub(/e/, '') << "</sup>"
        end
        evalue.to_f.round(1).to_s << e.to_s 
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

          @report = @job.method(@job_report_association).call.build

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
              @report.evalue      = format_evalue(hsp.evalue)
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

          # Hsps are only reported if a query hit against the Blast db.
          # Only save the @report if bit_score exists.
          if @report.bit_score && 
            (@report.bit_score.to_i > @min_score.to_i)
            @report.results = true
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
          @report = @job.method(@job_report_association).call.build
          @report.results = false
          unless @report.save!
            @logger.log(
              "ActiveRecord",
              "Unable to save Blast results to database.",
              81,
              @tmp_files
            )
          end
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
