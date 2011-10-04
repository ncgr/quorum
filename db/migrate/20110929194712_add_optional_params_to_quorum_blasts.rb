class AddOptionalParamsToQuorumBlasts < ActiveRecord::Migration
  def change
    add_column :quorum_blasts, :expectation, :string
    add_column :quorum_blasts, :max_score, :integer
    add_column :quorum_blasts, :min_bit_score, :integer
    add_column :quorum_blasts, :gapped_alignments, :boolean
    add_column :quorum_blasts, :gap_opening_penalty, :integer
    add_column :quorum_blasts, :gap_extension_penalty, :integer
  end
end
