class AddPercentIdentityAndMismatchToTblastx < ActiveRecord::Migration
  def change
    add_column :quorum_tblastx_job_reports, :pct_identity, :float
    add_column :quorum_tblastx_job_reports, :mismatch, :integer
  end
end
