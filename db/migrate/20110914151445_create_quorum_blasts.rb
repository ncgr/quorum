class CreateQuorumBlasts < ActiveRecord::Migration
  def change
    create_table :quorum_blasts do |t|
      t.text :sequence, :null => false
      t.string :expectation
      t.integer :max_score
      t.integer :min_bit_score
      t.boolean :gapped_alignments
      t.integer :gap_opening_penalty
      t.integer :gap_extension_penalty

      t.timestamps
    end
  end
end
