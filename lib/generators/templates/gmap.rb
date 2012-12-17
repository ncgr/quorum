$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))

require 'logger'

module Quorum
  module SearchTools
    #
    # Gmap Search Tool
    #
    class Gmap

      class QuorumJob < ActiveRecord::Base
        self.table_name = "quorum_jobs"

        has_one :quorum_gmap_job,
          :foreign_key => "job_id"
        has_many :quorum_gmap_job_reports,
          :foreign_key => "gmap_job_id"
      end

      class QuorumGmapJob < ActiveRecord::Base
        self.table_name = "quorum_gmap_jobs"
        belongs_to :quorum_job
        has_many :quorum_gmap_job_reports
      end

      class QuorumGmapJobReport < ActiveRecord::Base
        self.table_name = "quorum_gmap_job_reports"
        belongs_to :quorum_gmap_job
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

        ## Create for method invocation ##
        @job_association        = "quorum_#{@algorithm}_job".to_sym
        @job_report_association = "quorum_#{@algorithm}_job_reports".to_sym

        @intron_len     = @job.method(@job_association).call.intron_len
        @total_len      = @job.method(@job_association).call.total_len
        @chimera_margin = @job.method(@job_association).call.chimera_margin
        @prune_level    = @job.method(@job_association).call.prune_level
        @cross_species  = @job.method(@job_association).call.cross_species
        @splicing       = @job.method(@job_association).call.splicing

        @dbs = @job.method(@job_association).call.gmap_dbs.split(';')

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
      # Gmap command
      #
      def generate_gmap_cmds
        @na_fasta = File.join(@tmp, @hash + ".na.fa")
        File.open(@na_fasta, "w") { |f| f << @na_sequence }

        @cmds = []

        @dbs.each do |db|
          gmap = "gmap " <<
          "-D #{@search_database} " <<
          "-d #{db} " <<
          "-t #{@threads} " <<
          "-p #{@prune_level} " <<
          "-x #{@chimera_margin} " <<
          "-f samse "
          if @splicing
            gmap << "-K #{@intron_len} "
            gmap << "-L #{@total_len} "
          else
            gmap << "--nosplicing "
          end
          gmap << @na_fasta
          gmap << " > " + File.join(@tmp, @hash + "." + db + ".sam")
          gmap << " 2> /dev/null"
          @cmds << gmap
        end
      end

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
        @logger.log("GMAP", "#{@algorithm} report empty.")
      end

      def save_results
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
      # Parse SAM file(s) and save results.
      #
      def parse_and_save_results
        results = false
        @dbs.each do |db|
          file = File.join(@tmp, @hash + "." + db + ".sam")
          if File.size(file) > 0
            lines = IO.readlines(file)
            lines.each do |line|
              next if line =~ /^@/
              l = line.chomp.split(/\t/)

              @data = {}

              @data[:query]       = l[0]
              @data[:flag]        = l[1]
              @data[:reference]   = l[2]
              @data[:position]    = l[3]
              @data[:map_quality] = l[4]
              @data[:cigar]       = l[5]
              @data[:rnext]       = l[6]
              @data[:pnext]       = l[7]
              @data[:temp_len]    = l[8]
              @data[:seq]         = l[9]
              @data[:quality]     = l[10]
              @data[:sam_options] = l.slice(11, l.length).join("\t")

              save_results

              results = true
            end
          end
        end

        unless results
          save_empty_results
        end
      end

      #
      # Remove tmp files.
      #
      def remove_tmp_files
        FileUtils.rm(Dir.glob(@tmp_files)) if @tmp_files
      end

      public

      #
      # Execute Gmap on a given dataset.
      #
      def execute_gmap
        generate_gmap_cmds
        @logger.log("GMAP", @cmds.join('; '))

        @cmds.each { |c| system(c) }

        # Wrap these methods in a transaction to prevent premature return.
        @job.method(@job_report_association).call.transaction do
          parse_and_save_results
        end

        remove_tmp_files
      end

    end
  end
end
