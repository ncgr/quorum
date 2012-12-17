module Quorum
  class JobData

    attr_accessor :values

    def initialize
      @values = []
    end

    def no_results
      @values = [{ results: false }]
    end

    def not_enqueued
      no_results
      @values = [{ enqueued: false }.merge(@values[0])]
    end

  end
end
