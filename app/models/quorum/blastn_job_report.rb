module Quorum
  class BlastnJobReport < ActiveRecord::Base
    belongs_to :blastn_job
    scope :default_order, order("query ASC, bit_score DESC")
  end
end
