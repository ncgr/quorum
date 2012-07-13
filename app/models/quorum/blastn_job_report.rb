module Quorum
  class BlastnJobReport < ActiveRecord::Base

    belongs_to :blastn_job
    scope :default_order, order("query ASC, bit_score DESC")

    #
    # Simple search interface on query and id.
    #
    def self.search(params)
      if params[:blastn_id].present? && params[:query].present?
        where(
          "quorum_blastn_job_reports.id IN (?) AND query = ?",
          params[:blastn_id].split(","),
          params[:query]
        )
      elsif params[:blastn_id].present?
        where(
          "quorum_blastn_job_reports.id IN (?)",
          params[:blastn_id].split(",")
        )
      elsif params[:query].present?
        where("query = ?", params[:query])
      else
        self
      end
    end

  end
end
