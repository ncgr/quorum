class CreateHmmerJobs < ActiveRecord::Migration
  def change
    create_table :quorum_hmmer_jobs do |t|
      t.string :expectation
      t.integer :min_score
      t.boolean :queue

      t.references :job

      t.timestamps
    end
  end
end
