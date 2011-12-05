module Quorum
  class TblastnJobReport < ActiveRecord::Base
    belongs_to :tblastn_job
    scope :default_order, order("query ASC, bit_score DESC")
    scope :by_query, lambda { |query| where("query = ?", query) }
  end
end
