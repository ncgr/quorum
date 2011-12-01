module Quorum
  class HmmerJobReport < ActiveRecord::Base
    belongs_to :hmmer_job
    scope :default_order, order("query ASC, score DESC")
  end
end
