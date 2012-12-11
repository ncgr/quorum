module Quorum
  class GmapJobReport < ActiveRecord::Base

    extend Quorum::JobReportSearcher

    belongs_to :gmap_job
    scope :default_order, order("query ASC")

  end
end
