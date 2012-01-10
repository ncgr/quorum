require 'spec_helper'
require File.expand_path("../../dummy/quorum/lib/search_tools/blast", __FILE__)

describe "Quorum::SearchTools::Blast" do
  describe "#execute_blast" do
    before(:each) do
      # Set args as though we executed bin/search.
      @args = {
        :search_tool     => "blastn",
        :id              => nil,
        :log_directory   => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        ),
        :tmp_directory   => File.expand_path(
          "../../dummy/quorum/tmp", __FILE__
        ),
        :search_database => File.expand_path(
          "../../dummy/quorum/blastdb", __FILE__
        ),
        :threads         => 1
      }

      @job = Quorum::Job.new()

      @job.sequence = File.open(
        File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      ).read

      @job.build_blastn_job
      @job.blastn_job.queue     = true
      @job.blastn_job.blast_dbs = ["test"]

      @job.build_blastx_job
      @job.blastx_job.queue     = true
      @job.blastx_job.blast_dbs = ["test"]

      @job.build_tblastn_job
      @job.tblastn_job.queue     = true
      @job.tblastn_job.blast_dbs = ["test"]

      @job.build_blastp_job
      @job.blastp_job.queue     = true
      @job.blastp_job.blast_dbs = ["test"]
    end
  
    it "executes blastn on a given dataset" do
      @job.stub(:queue_workers)
      @job.save!

      @args[:id] = @job.id

      blast = Quorum::SearchTools::Blast.new(@args)
      expect {
        blast.execute_blast
      }.to_not raise_error

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0
    end 

    it "executes blastx on a given dataset" do
      @job.stub(:queue_workers)
      @job.save!

      @args[:search_tool] = "blastx"
      @args[:id]          = @job.id

      blast = Quorum::SearchTools::Blast.new(@args)
      expect {
        blast.execute_blast
      }.to raise_error(SystemExit)

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0
    end 

    it "executes tblastn on a given dataset" do
      @job.stub(:queue_workers)
      @job.save!

      @args[:search_tool] = "tblastn"
      @args[:id]          = @job.id

      blast = Quorum::SearchTools::Blast.new(@args)
      expect {
        blast.execute_blast
      }.to raise_error(SystemExit)

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0
    end 

    it "executes blastp on a given dataset" do
      @job.stub(:queue_workers)
      @job.save!

      @args[:search_tool] = "blastp"
      @args[:id]          = @job.id

      blast = Quorum::SearchTools::Blast.new(@args)
      expect {
        blast.execute_blast
      }.to_not raise_error

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0
    end 

  end
end
