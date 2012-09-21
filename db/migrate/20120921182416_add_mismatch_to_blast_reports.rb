class AddMismatchToBlastReports < ActiveRecord::Migration
  def change
    add_column :quorum_blastn_job_reports, :mismatch, :integer
    add_column :quorum_blastx_job_reports, :mismatch, :integer
    add_column :quorum_tblastn_job_reports, :mismatch, :integer
    add_column :quorum_blastp_job_reports, :mismatch, :integer
  end
end
