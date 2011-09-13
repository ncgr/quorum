class CreateBlasts < ActiveRecord::Migration
  def change
    create_table :blasts do |t|
      t.string :sequence_type
      t.string :sequence
      t.text :results

      t.timestamps
    end
  end
end
