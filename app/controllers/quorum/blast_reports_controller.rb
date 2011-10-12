module Quorum
  class BlastReportsController < ApplicationController
    def show
      @blast_report = BlastReport.find(params[:id])
    end
  end
end
