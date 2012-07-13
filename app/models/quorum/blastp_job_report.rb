module Quorum
  class BlastpJobReport < ActiveRecord::Base

    belongs_to :blastp_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query and id.
    #
    def self.search(params)
      if params[:blastp_id].present? && params[:query].present?
        where(
          "quorum_blastp_job_reports.id IN (?) AND query = ?",
          params[:blastp_id].split(","),
          params[:query]
        )
      elsif params[:blastp_id].present?
        where(
          "quorum_blastp_job_reports.id IN (?)",
          params[:blastp_id].split(",")
        )
      elsif params[:query].present?
        where("query = ?", params[:query])
      else
        self
      end
    end

  end
end
