module Quorum
  class TblastnJobReport < ActiveRecord::Base

    belongs_to :tblastn_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query and id.
    #
    def self.search(params)
      if params[:tblastn_id].present? && params[:query].present?
        where(
          "quorum_tblastn_job_reports.id IN (?) AND query = ?",
          params[:tblastn_id].split(","),
          params[:query]
        )
      elsif params[:tblastn_id].present?
        where(
          "quorum_tblastn_job_reports.id IN (?)",
          params[:tblastn_id].split(",")
        )
      elsif params[:query].present?
        where("query = ?", params[:query])
      else
        self
      end
    end

  end
end
