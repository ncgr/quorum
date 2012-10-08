class RenameMaxScoreColumn < ActiveRecord::Migration
  def up
    rename_column :quorum_blastn_jobs, :max_score, :max_target_seqs
    rename_column :quorum_blastp_jobs, :max_score, :max_target_seqs
    rename_column :quorum_blastx_jobs, :max_score, :max_target_seqs
    rename_column :quorum_tblastn_jobs, :max_score, :max_target_seqs
  end

  def down
    rename_column :quorum_blastn_jobs, :max_target_seqs, :max_score
    rename_column :quorum_blastp_jobs, :max_target_seqs, :max_score
    rename_column :quorum_blastx_jobs, :max_target_seqs, :max_score
    rename_column :quorum_tblastn_jobs, :max_target_seqs, :max_score
  end
end
