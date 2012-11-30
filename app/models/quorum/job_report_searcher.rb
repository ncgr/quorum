module Quorum
  module JobReportSearcher

    #
    # Simple search interface on query, id and job id for job reports.
    #
    def search(algo, params)
      algo.downcase!
      klass = "quorum/#{algo}_job_report".camelize.constantize
      if params[:"#{algo}_id"].present? && params[:query].present?
        klass.where(
          "quorum_#{algo}_job_reports.id IN (?) AND query = ? " <<
          "AND #{algo}_job_id = ?",
          params[:"#{algo}_id"].split(","),
          params[:query],
          params[:id]
        )
      elsif params[:"#{algo}_id"].present?
        klass.where(
          "quorum_#{algo}_job_reports.id IN (?) AND #{algo}_job_id = ? ",
          params[:"#{algo}_id"].split(","),
          params[:id]
        )
      elsif params[:query].present?
        klass.where(
          "query = ? AND #{algo}_job_id = ?",
          params[:query],
          params[:id]
        )
      else
        klass.where("#{algo}_job_id = ?", params[:id])
      end
    end

  end
end
