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

      end

      public

      def execute_hmmer

      end

    end
  end
end
