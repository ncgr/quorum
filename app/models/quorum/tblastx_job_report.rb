module Quorum
  class TblastxJobReport < ActiveRecord::Base
    belongs_to :tblastx_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query, id and job id.
    #
    def self.search(params)
      if params[:tblastx_id].present? && params[:query].present?
        where(
          "quorum_tblastx_job_reports.id IN (?) AND query = ? " <<
          "AND tblastx_job_id = ?",
          params[:tblastx_id].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:tblastx_id].present?
        where(
          "quorum_tblastx_job_reports.id IN (?) AND tblastx_job_id = ? ",
          params[:tblastx_id].split(","),
          params[:id]
        )
      elsif params[:query].present?
        where(
          "query = ? AND tblastx_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        where("tblastx_job_id = ?", params[:id])
      end
    end

  end
end
