$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))

require 'bio-blastxmlparser'
require 'logger'

module Quorum
  module SearchTools
    #
    # Blast Search Tool
    #
    class Blast

      class QuorumJob < ActiveRecord::Base
        self.table_name = "quorum_jobs"

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
        self.table_name = "quorum_blastn_jobs"
        belongs_to :quorum_job
        has_many :quorum_blastn_job_reports
      end

      class QuorumBlastnJobReport < ActiveRecord::Base
        self.table_name = "quorum_blastn_job_reports"
        belongs_to :quorum_blastn_job
      end

      class QuorumBlastxJob < ActiveRecord::Base
        self.table_name = "quorum_blastx_jobs"
        belongs_to :quorum_job
        has_many :quorum_blastx_job_reports
      end

      class QuorumBlastxJobReport < ActiveRecord::Base
        self.table_name = "quorum_blastx_job_reports"
        belongs_to :quorum_blastx_job
      end

      class QuorumTblastnJob < ActiveRecord::Base
        self.table_name = "quorum_tblastn_jobs"
        belongs_to :quorum_job
        has_many :quorum_tblastn_job_reports
      end

      class QuorumTblastnJobReport < ActiveRecord::Base
        self.table_name = "quorum_tblastn_job_reports"
        belongs_to :quorum_tblastn_job
      end

      class QuorumBlastpJob < ActiveRecord::Base
        self.table_name = "quorum_blastp_jobs"
        belongs_to :quorum_job
        has_many :quorum_blastp_job_reports
      end

      class QuorumBlastpJobReport < ActiveRecord::Base
        self.table_name = "quorum_blastp_job_reports"
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

        @logger = Quorum::Logger.new(@log_directory)

        begin
          @job = QuorumJob.find(@id)
        rescue Exception => e
          @logger.log("ActiveRecord", e.message, 1)
        end

        @na_sequence = @job.na_sequence
        @aa_sequence = @job.aa_sequence

        ## Create for method invocation ##
        @job_association        = "quorum_#{@algorithm}_job".to_sym
        @job_report_association = "quorum_#{@algorithm}_job_reports".to_sym

        @filter                = @job.method(@job_association).call.filter
        @expectation           = @job.method(@job_association).call.expectation
        @max_target_seqs       = @job.method(@job_association).call.max_target_seqs
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
      # Blastn command
      #
      def generate_blastn_cmd
        blastn = "blastn " <<
        "-db \"#{@db}\" " <<
        "-query #{@na_fasta} " <<
        "-outfmt 5 " <<
        "-num_threads #{@threads} " <<
        "-evalue #{@expectation} " <<
        "-max_target_seqs #{@max_target_seqs} " <<
        "-out #{@out} "
        if @gapped_alignments
          if @gap_opening_penalty && @gap_extension_penalty
            blastn << "-gapopen #{@gap_opening_penalty} "
            blastn << "-gapextend #{@gap_extension_penalty} "
          end
        else
          blastn << "-ungapped "
        end
        blastn << "-dust #{@filter ? 'yes' : 'no'} "
        blastn
      end

      #
      # Blastx command
      #
      def generate_blastx_cmd
        blastx = "blastx " <<
        "-db \"#{@db}\" " <<
        "-query #{@na_fasta} " <<
        "-outfmt 5 " <<
        "-num_threads #{@threads} " <<
        "-evalue #{@expectation} " <<
        "-max_target_seqs #{@max_target_seqs} " <<
        "-out #{@out} "
        if @gapped_alignments
          if @gap_opening_penalty && @gap_extension_penalty
            blastx << "-gapopen #{@gap_opening_penalty} "
            blastx << "-gapextend #{@gap_extension_penalty} "
          end
        else
          blastx << "-ungapped "
        end
        blastx << "-seg #{@filter ? 'yes' : 'no'} "
        blastx
      end

      #
      # Tblastn command
      #
      def generate_tblastn_cmd
        tblastn = "tblastn " <<
        "-db \"#{@db}\" " <<
        "-query #{@aa_fasta} " <<
        "-outfmt 5 " <<
        "-num_threads #{@threads} " <<
        "-evalue #{@expectation} " <<
        "-max_target_seqs #{@max_target_seqs} " <<
        "-out #{@out} "
        if @gapped_alignments
          if @gap_opening_penalty && @gap_extension_penalty
            tblastn << "-gapopen #{@gap_opening_penalty} "
            tblastn << "-gapextend #{@gap_extension_penalty} "
          end
          tblastn << "-comp_based_stats D "
        else
          tblastn << "-ungapped "
          tblastn << "-comp_based_stats F "
        end
        tblastn << "-seg #{@filter ? 'yes' : 'no'} "
        tblastn
      end

      #
      # Blastp command
      #
      def generate_blastp_cmd
        blastp = "blastp " <<
        "-db \"#{@db}\" " <<
        "-query #{@aa_fasta} " <<
        "-outfmt 5 " <<
        "-num_threads #{@threads} " <<
        "-evalue #{@expectation} " <<
        "-max_target_seqs #{@max_target_seqs} " <<
        "-out #{@out} "
        if @gapped_alignments
          if @gap_opening_penalty && @gap_extension_penalty
            blastp << "-gapopen #{@gap_opening_penalty} "
            blastp << "-gapextend #{@gap_extension_penalty} "
          end
          blastp << "-comp_based_stats D "
        else
          blastp << "-ungapped "
          blastp << "-comp_based_stats F "
        end
        blastp << "-seg #{@filter ? 'yes' : 'no'} "
        blastp
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

        case @algorithm
        when "blastn"
          @cmd << generate_blastn_cmd
        when "blastx"
          @cmd << generate_blastx_cmd
        when "tblastn"
          @cmd << generate_tblastn_cmd
        when "blastp"
          @cmd << generate_blastp_cmd
        end
      end

      #
      # Format Blast report hit_display_id and hit_def.
      #
      # For added flexibility, Quorum doesn't parse seqids or deflines.
      # Instead, format_hit splits the hit_def on whitespace and
      # reports hit_display_id as the first element and hit_def as the second.
      #
      def format_hit(str)
        hit_display_id  = ""
        hit_def = ""

        hit = str.split(" ", 2)
        if hit.length < 2
          hit_display_id  = hit.first
          hit_def = "None"
        else
          hit_display_id  = hit.first
          hit_def = hit.last
        end

        return hit_display_id, hit_def
      end

      #
      # Save Blast Job Report
      #
      # Hsps are only reported if a query hit against the Blast db.
      # Only save the @data if bit_score exists and it's > the user
      # defined minimum score.
      #
      # Set the attribute results to true for downstream processes.
      #
      def save_hsp_results
        @data[:results] = true
        @data["#{@algorithm}_job_id".to_sym] = @job.method(@job_association).call.job_id

        job_report = @job.method(@job_report_association).call.build(@data)

        unless job_report.save!
          @logger.log(
            "ActiveRecord",
            "Unable to save #{@algorithm} results to database.",
            1,
            @tmp_files
          )
        end
      end

      #
      # Save empty Blast Job Report
      #
      # Set the attribute results to false for downstream processes.
      #
      def save_empty_results
        job_report = @job.method(@job_report_association).call.build(
          "#{@algorithm}_job_id" => @job.method(@job_association).call.job_id,
          "results"              => false
        )
        unless job_report.save!
          @logger.log(
            "ActiveRecord",
            "Unable to save #{@algorithm} results to database.",
            1,
            @tmp_files
          )
        end
        @logger.log("NCBI Blast", "#{@algorithm} report empty.")
      end

      #
      # Parse and save Blast results.
      #
      # Parse the Blast XML output and save results.
      #
      def parse_and_save_results
        @results = false # Did the xml contain results?

        if File.size(@out) > 0
          report = Bio::Blast::XmlIterator.new(@out)
          report.to_enum.each do |iteration|

            @data = {}

            @data[:query]     = iteration.query_def.split(" ").first
            @data[:query_len] = iteration.query_len

            iteration.each do |hit|
              @data[:hit_display_id], @data[:hit_def] = format_hit(hit.hit_def)

              @data[:hit_id]        = hit.hit_id
              @data[:hit_accession] = hit.accession
              @data[:hit_len]       = hit.len

              hit.each do |hsp|
                @data[:hsp_num]     = hsp.hsp_num
                @data[:bit_score]   = hsp.bit_score
                @data[:score]       = hsp.score
                @data[:evalue]      = hsp.evalue
                @data[:query_from]  = hsp.query_from
                @data[:query_to]    = hsp.query_to
                @data[:hit_from]    = hsp.hit_from
                @data[:hit_to]      = hsp.hit_to
                @data[:query_frame] = hsp.query_frame
                @data[:hit_frame]   = hsp.hit_frame
                @data[:identity]    = hsp.identity
                @data[:positive]    = hsp.positive
                @data[:gaps]        = hsp.gaps
                @data[:align_len]   = hsp.align_len
                @data[:qseq]        = hsp.qseq
                @data[:hseq]        = hsp.hseq
                @data[:midline]     = hsp.midline

                if @data[:bit_score] &&
                  (@data[:bit_score].to_i > @min_score.to_i)
                  @results = true
                  save_hsp_results
                end

              end
            end
          end
        end

        save_empty_results unless @results
      end

      #
      # Group record ids of hsps belonging to the same query and hit_accession.
      #
      def add_hps_groups_to_reports
        groups = {}

        query_hit_acc = @job.method(
          @job_report_association
        ).call.select("DISTINCT query, hit_accession")

        # Populate the hash of hashes with correct query and hit_accession.
        query_hit_acc.each do |q|
          groups[q.query] = {}
        end
        query_hit_acc.each do |q|
          groups[q.query][q.hit_accession] = []
        end

        # Group record ids.
        reports = @job.method(@job_report_association).call.order("id ASC")
        reports.each do |r|
          if groups[r.query][r.hit_accession]
            groups[r.query][r.hit_accession] << r.id
          end
        end

        # Save hsp_group as a comma delimited string.
        reports.each do |r|
          if groups[r.query][r.hit_accession]
            if groups[r.query][r.hit_accession].length > 1
              r.hsp_group = groups[r.query][r.hit_accession].join(",")
              unless r.save!
                @logger.log(
                  "ActiveRecord",
                  "Unable to save #{@algorithm} results to database.",
                  1,
                  @tmp_files
                )
              end
            end
          end
        end
      end

      #
      # Remove tmp files.
      #
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

        # Wrap these methods in a transaction to prevent premature return.
        @job.method(@job_report_association).call.transaction do
          parse_and_save_results
          add_hps_groups_to_reports
        end

        remove_tmp_files
      end

    end
  end
end
