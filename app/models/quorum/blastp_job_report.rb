module Quorum
  class BlastpJobReport < ActiveRecord::Base
    belongs_to :blastp_job
    scope :default_order, order("query ASC, bit_score DESC")
  end
end
