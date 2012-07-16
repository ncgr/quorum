module Quorum
  class BlastxJobReport < ActiveRecord::Base

    belongs_to :blastx_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query, id and job id.
    #
    def self.search(params)
      if params[:blastx_id].present? && params[:query].present?
        where(
          "quorum_blastx_job_reports.id IN (?) AND query = ? " <<
          "AND blastx_job_id = ?",
          params[:blastx_id].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:blastx_id].present?
        where(
          "quorum_blastx_job_reports.id IN (?) AND blastx_job_id = ? ",
          params[:blastx_id].split(","),
          params[:id]
        )
      elsif params[:query].present?
        where(
          "query = ? AND blastx_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        where("blastx_job_id = ?", params[:id])
      end
    end

  end
end
