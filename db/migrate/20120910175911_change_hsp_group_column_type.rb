class ChangeHspGroupColumnType < ActiveRecord::Migration
  def up
    change_column :quorum_blastn_job_reports, :hsp_group, :text
    change_column :quorum_blastx_job_reports, :hsp_group, :text
    change_column :quorum_tblastn_job_reports, :hsp_group, :text
    change_column :quorum_blastp_job_reports, :hsp_group, :text
  end

  def down
    change_column :quorum_blastn_job_reports, :hsp_group, :string
    change_column :quorum_blastx_job_reports, :hsp_group, :string
    change_column :quorum_tblastn_job_reports, :hsp_group, :string
    change_column :quorum_blastp_job_reports, :hsp_group, :string
  end
end
