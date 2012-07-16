module Quorum
  class BlastnJobReport < ActiveRecord::Base

    belongs_to :blastn_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query, id and job id.
    #
    def self.search(params)
      if params[:blastn_id].present? && params[:query].present?
        where(
          "quorum_blastn_job_reports.id IN (?) AND query = ? " <<
          "AND blastn_job_id = ?",
          params[:blastn_id].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:blastn_id].present?
        where(
          "quorum_blastn_job_reports.id IN (?) AND blastn_job_id = ? ",
          params[:blastn_id].split(","),
          params[:id]
        )
      elsif params[:query].present?
        where(
          "query = ? AND blastn_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        where("blastn_job_id = ?", params[:id])
      end
    end

  end
end
