module Quorum
  class TblastnJobReport < ActiveRecord::Base

    extend Quorum::JobReportSearcher

    belongs_to :tblastn_job
    scope :default_order, order("query ASC, bit_score DESC")

  end
end
