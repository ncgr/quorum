require 'spec_helper'
require File.expand_path("../../dummy/quorum/lib/fetch_tools/blast_db", __FILE__)

describe "Quorum::FetchTools::BlastDb" do
  describe "#execute_blast_db_cmd" do
    before(:each) do
      # Set the args as though we executed bin/fetch
      @args = {
        :fetch_tool           => "blastdbcmd",
        :blast_hit_id         => nil,
        :blast_hit_display_id => nil,
        :blast_algo           => nil,
        :fetch_database_names => "test",

        :log_directory   => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        ),
        :tmp_directory   => File.expand_path(
          "../../dummy/quorum/tmp", __FILE__
        ),
        :fetch_database  => File.expand_path(
          "../../dummy/quorum/blastdb", __FILE__
        )
      }
    end

    it "executes blastdbcmd for blastn and returns correct sequence" do
      @args[:blast_hit_id]         = "gnl|BL_ORD_ID|0"
      @args[:blast_hit_display_id] = "TOG900080"
      @args[:blast_algo]           = "blastn"

      seqs = File.readlines(
        File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      )
      seqs[0].gsub!(">", "")
      seqs.insert(0, ">" + @args[:blast_hit_id] + " ")

      # Sequence #execute_blast_db_cmd should return.
      seq = seqs.slice(0,3).join("").gsub("\n", "")

      fetch = Quorum::FetchTools::BlastDb.new(@args)
      lambda {
        output = capture(:stdout) {
          fetch.execute_blast_db_cmd
        }
        output.gsub("\n", "").should eq(seq)
      }.should_not raise_error
    end

    it "returns error message if filtered sequence.length != 1" do
      @args[:blast_hit_id]         = "null"
      @args[:blast_hit_display_id] = "null"
      @args[:blast_algo]           = "blastp"
      fetch = Quorum::FetchTools::BlastDb.new(@args)
      lambda {
        output = capture(:stdout) {
          fetch.execute_blast_db_cmd
        }
        output.should eq("An error occurred while processing your request.")
      }.should_not raise_error
    end
  end
end
