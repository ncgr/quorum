class CreateGmapJobReports < ActiveRecord::Migration
  def change
    create_table :quorum_gmap_job_reports do |t|
      t.string :query
      t.integer :flag
      t.string :reference
      t.integer :position
      t.integer :map_quality
      t.text :cigar
      t.text :rnext
      t.integer :pnext
      t.integer :temp_len
      t.text :seq
      t.text :quality
      t.text :sam_options
      t.boolean :results

      t.references :gmap_job

      t.timestamps
    end
  end
end
