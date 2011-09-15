class CreateQuorumBlasts < ActiveRecord::Migration
  def change
    create_table :quorum_blasts do |t|
      t.string :sequence_type, :null => false
      t.text :sequence, :null => false
      t.text :results

      t.timestamps
    end
  end
end
