$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))

require 'logger'

module Quorum
  module SearchTools
    #
    # Hmmer Search Tool
    #
    class Hmmer

      class QuorumJob < ActiveRecord::Base
        has_one :quorum_hmmer_job, 
          :foreign_key => "job_id"
        has_many :quorum_hmmer_job_reports, 
          :foreign_key => "hmmer_job_id"
      end

      class QuorumHmmerJob < ActiveRecord::Base
        belongs_to :quorum_job
        has_many :quorum_hmmer_job_reports
      end

      class QuorumHmmerJobReport < ActiveRecord::Base
        belongs_to :quorum_hmmer_job
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

        @aa_sequence = @job.aa_sequence
        @expectation = @job.quorum_hmmer_job.expectation
        @min_score   = @job.quorum_hmmer_job.min_bit_score

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
      # Generate Hmmer Command
      #
      def generate_hmmer_cmd
        @cmd = ""

        @aa_fasta = File.join(@tmp, @hash + ".aa.fa")
        File.open(@aa_fasta, "w") { |f| f << @aa_sequence }

        @out = File.join(@tmp, @hash + ".out.hmm") 
        File.new(@out, "w")

        @cmd = "hmmscan " <<
        "-o #{@out} " <<
        "-E #{@expectation} " <<
        "-T #{@min_score} " <<
        "#{@search_database} "<<
        "#{@aa_fasta} "
      end

      def parse_and_save_results

      end

      def remove_tmp_files
        `rm #{@tmp_files}` if @tmp_files
      end

      public

      def execute_hmmer
        generate_hmmer_cmd
        @logger.log("Hmmer", @cmd)
        system(@cmd)
        parse_and_save_results
        remove_tmp_files
      end

    end
  end
end
