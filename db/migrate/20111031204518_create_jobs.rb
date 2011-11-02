class CreateJobs < ActiveRecord::Migration
  def change
    create_table :quorum_jobs do |t|
      t.text :sequence, :null => false
      t.text :na_sequence, :null => true
      t.text :aa_sequence, :null => true
      t.string :sequence_hash, :nul => true

      t.timestamps
    end
  end
end
