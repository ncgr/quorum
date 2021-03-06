class CreateTblastnJobs < ActiveRecord::Migration
  def change
    create_table :quorum_tblastn_jobs do |t|
      t.string :expectation
      t.integer :max_score
      t.integer :min_bit_score
      t.boolean :filter
      t.boolean :gapped_alignments
      t.integer :gap_opening_penalty
      t.integer :gap_extension_penalty
      t.text :blast_dbs
      t.boolean :queue

      t.references :job

      t.timestamps
    end
  end
end
