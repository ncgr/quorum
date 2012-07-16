module Quorum
  class TblastnJobReport < ActiveRecord::Base

    belongs_to :tblastn_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query, id and job id.
    #
    def self.search(params)
      if params[:tblastn_id].present? && params[:query].present?
        where(
          "quorum_tblastn_job_reports.id IN (?) AND query = ? " <<
          "AND tblastn_job_id = ?",
          params[:tblastn_id].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:tblastn_id].present?
        where(
          "quorum_tblastn_job_reports.id IN (?) AND tblastn_job_id = ? ",
          params[:tblastn_id].split(","),
          params[:id]
        )
      elsif params[:query].present?
        where(
          "query = ? AND tblastn_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        where("tblastn_job_id = ?", params[:id])
      end
    end

  end
end
