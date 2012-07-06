module Quorum
  class TblastnJobReport < ActiveRecord::Base
    extend Quorum::DataExport

    belongs_to :tblastn_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query and id.
    #
    def self.search(params)
      if params[:algo_id].present? && params[:query].present?
        where(
          "quorum_tblastn_job_reports.id IN (?) AND query = ?",
          params[:algo_id].split(","),
          params[:query]
        )
      elsif params[:algo_id].present?
        where(
          "quorum_tblastn_job_reports.id IN (?)",
          params[:algo_id].split(",")
        )
      elsif params[:query].present?
        where("query = ?", params[:query])
      else
        self
      end
    end

  end
end
