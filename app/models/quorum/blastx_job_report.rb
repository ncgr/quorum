module Quorum
  class BlastxJobReport < ActiveRecord::Base
    belongs_to :blastx_job
    scope :default_order, order("query ASC, bit_score DESC")
  end
end
