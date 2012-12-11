class CreateGmapJobs < ActiveRecord::Migration
  def change
    create_table :quorum_gmap_jobs do |t|
      t.integer :intron_len
      t.integer :total_len
      t.integer :chimera_margin
      t.integer :prune_level
      t.boolean :cross_species
      t.boolean :splicing
      t.text :gmap_dbs
      t.boolean :queue

      t.references :job

      t.timestamps
    end
  end
end
