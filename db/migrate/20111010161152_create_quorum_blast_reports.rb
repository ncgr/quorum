class CreateQuorumBlastReports < ActiveRecord::Migration
  def change
    create_table :quorum_blast_reports do |t|
      t.string :query
      t.integer :query_len
      t.string :hit_id
      t.string :hit_def
      t.integer :hit_accession
      t.integer :hit_len
      t.integer :bit_score
      t.integer :score
      t.string :evalue
      t.integer :query_from
      t.integer :query_to
      t.integer :hit_from
      t.integer :hit_to
      t.string :query_frame
      t.string :hit_frame
      t.integer :identity
      t.integer :positive
      t.integer :gaps
      t.integer :align_len
      t.text :qseq
      t.text :hseq
      t.text :midline

      t.references :blast

      t.timestamps
    end
  end
end
