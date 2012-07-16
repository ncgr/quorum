module Quorum
  class BlastpJobReport < ActiveRecord::Base

    belongs_to :blastp_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query, id and job id.
    #
    def self.search(params)
      if params[:blastp_id].present? && params[:query].present?
        where(
          "quorum_blastp_job_reports.id IN (?) AND query = ? " <<
          "AND blastp_job_id = ?",
          params[:blastp_id].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:blastp_id].present?
        where(
          "quorum_blastp_job_reports.id IN (?) AND blastp_job_id = ? ",
          params[:blastp_id].split(","),
          params[:id]
        )
      elsif params[:query].present?
        where(
          "query = ? AND blastp_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        where("blastp_job_id = ?", params[:id])
      end
    end

  end
end
