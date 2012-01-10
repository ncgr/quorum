# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120109232902) do

  create_table "quorum_blastn_job_reports", :force => true do |t|
    t.string   "query"
    t.integer  "query_len"
    t.string   "hit_id"
    t.string   "hit_def"
    t.string   "hit_accession"
    t.integer  "hit_len"
    t.integer  "hsp_num"
    t.string   "hsp_group"
    t.integer  "bit_score"
    t.integer  "score"
    t.string   "evalue"
    t.integer  "query_from"
    t.integer  "query_to"
    t.integer  "hit_from"
    t.integer  "hit_to"
    t.string   "query_frame"
    t.string   "hit_frame"
    t.integer  "identity"
    t.integer  "positive"
    t.integer  "align_len"
    t.text     "qseq"
    t.text     "hseq"
    t.text     "midline"
    t.boolean  "results"
    t.integer  "blastn_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hit_display_id"
  end

  create_table "quorum_blastn_jobs", :force => true do |t|
    t.string   "expectation"
    t.integer  "max_score"
    t.integer  "min_bit_score"
    t.boolean  "filter"
    t.boolean  "gapped_alignments"
    t.integer  "gap_opening_penalty"
    t.integer  "gap_extension_penalty"
    t.text     "blast_dbs"
    t.boolean  "queue"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quorum_blastp_job_reports", :force => true do |t|
    t.string   "query"
    t.integer  "query_len"
    t.string   "hit_id"
    t.string   "hit_def"
    t.string   "hit_accession"
    t.integer  "hit_len"
    t.integer  "hsp_num"
    t.string   "hsp_group"
    t.integer  "bit_score"
    t.integer  "score"
    t.string   "evalue"
    t.integer  "query_from"
    t.integer  "query_to"
    t.integer  "hit_from"
    t.integer  "hit_to"
    t.string   "query_frame"
    t.string   "hit_frame"
    t.integer  "identity"
    t.integer  "positive"
    t.integer  "align_len"
    t.text     "qseq"
    t.text     "hseq"
    t.text     "midline"
    t.boolean  "results"
    t.integer  "blastp_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hit_display_id"
  end

  create_table "quorum_blastp_jobs", :force => true do |t|
    t.string   "expectation"
    t.integer  "max_score"
    t.integer  "min_bit_score"
    t.boolean  "filter"
    t.boolean  "gapped_alignments"
    t.integer  "gap_opening_penalty"
    t.integer  "gap_extension_penalty"
    t.text     "blast_dbs"
    t.boolean  "queue"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quorum_blastx_job_reports", :force => true do |t|
    t.string   "query"
    t.integer  "query_len"
    t.string   "hit_id"
    t.string   "hit_def"
    t.string   "hit_accession"
    t.integer  "hit_len"
    t.integer  "hsp_num"
    t.string   "hsp_group"
    t.integer  "bit_score"
    t.integer  "score"
    t.string   "evalue"
    t.integer  "query_from"
    t.integer  "query_to"
    t.integer  "hit_from"
    t.integer  "hit_to"
    t.string   "query_frame"
    t.string   "hit_frame"
    t.integer  "identity"
    t.integer  "positive"
    t.integer  "align_len"
    t.text     "qseq"
    t.text     "hseq"
    t.text     "midline"
    t.boolean  "results"
    t.integer  "blastx_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hit_display_id"
  end

  create_table "quorum_blastx_jobs", :force => true do |t|
    t.string   "expectation"
    t.integer  "max_score"
    t.integer  "min_bit_score"
    t.boolean  "filter"
    t.boolean  "gapped_alignments"
    t.integer  "gap_opening_penalty"
    t.integer  "gap_extension_penalty"
    t.text     "blast_dbs"
    t.boolean  "queue"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quorum_hmmer_jobs", :force => true do |t|
    t.string   "expectation"
    t.integer  "min_score"
    t.boolean  "queue"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quorum_jobs", :force => true do |t|
    t.text     "sequence",      :null => false
    t.text     "na_sequence"
    t.text     "aa_sequence"
    t.string   "sequence_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quorum_tblastn_job_reports", :force => true do |t|
    t.string   "query"
    t.integer  "query_len"
    t.string   "hit_id"
    t.string   "hit_def"
    t.string   "hit_accession"
    t.integer  "hit_len"
    t.integer  "hsp_num"
    t.string   "hsp_group"
    t.integer  "bit_score"
    t.integer  "score"
    t.string   "evalue"
    t.integer  "query_from"
    t.integer  "query_to"
    t.integer  "hit_from"
    t.integer  "hit_to"
    t.string   "query_frame"
    t.string   "hit_frame"
    t.integer  "identity"
    t.integer  "positive"
    t.integer  "align_len"
    t.text     "qseq"
    t.text     "hseq"
    t.text     "midline"
    t.boolean  "results"
    t.integer  "tblastn_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hit_display_id"
  end

  create_table "quorum_tblastn_jobs", :force => true do |t|
    t.string   "expectation"
    t.integer  "max_score"
    t.integer  "min_bit_score"
    t.boolean  "filter"
    t.boolean  "gapped_alignments"
    t.integer  "gap_opening_penalty"
    t.integer  "gap_extension_penalty"
    t.text     "blast_dbs"
    t.boolean  "queue"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
