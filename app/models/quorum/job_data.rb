module Quorum
  class JobData

    def initialize
      @data = []
    end

    def results
      @data
    end

    def no_results
      @data = [{ results: false }]
    end

    def not_enqueued
      no_results
      @data = [{ enqueued: false }.merge(@data[0])]
    end

  end
end
