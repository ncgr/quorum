require 'spec_helper'
require 'generators/templates/gmap'

describe "Quorum::SearchTools::Gmap" do
  before(:all) do
    file = File.expand_path("../../data/gmap.tar.gz", __FILE__)
    dest = File.expand_path("../../dummy/quorum/gmapdb", __FILE__)
    system("tar -C #{dest} -xzf #{file}")
  end

  describe "#execute_gmap non empty report" do
    before(:each) do
      # Set args as though we executed bin/search.
      @args = {
        :search_tool     => "gmap",
        :id              => nil,
        :log_directory   => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        ),
        :tmp_directory   => File.expand_path(
          "../../dummy/quorum/tmp", __FILE__
        ),
        :search_database => File.expand_path(
          "../../dummy/quorum/gmapdb", __FILE__
        ),
        :threads         => 1
      }

      @job = Quorum::Job.new()

      @job.sequence = File.open(
        File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      ).read

      @job.build_gmap_job
      @job.gmap_job.queue       = true
      @job.gmap_job.gmap_dbs    = ["test"]
      @job.gmap_job.prune_level = 0
      @job.gmap_job.splicing    = true
    end

    it "executes gmap on a given dataset" do
      @job.save!
      @args[:id] = @job.id

      gmap = Quorum::SearchTools::Gmap.new(@args)
      expect {
        gmap.execute_gmap
      }.to_not raise_error

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0
    end
  end

  describe "#execute_gmap empty report" do
    before(:each) do
      # Set args as though we executed bin/search.
      @args = {
        :search_tool     => "gmap",
        :id              => nil,
        :log_directory   => File.expand_path(
          "../../dummy/quorum/log", __FILE__
        ),
        :tmp_directory   => File.expand_path(
          "../../dummy/quorum/tmp", __FILE__
        ),
        :search_database => File.expand_path(
          "../../dummy/quorum/gmapdb", __FILE__
        ),
        :threads         => 1
      }

      @job = Quorum::Job.new()

      @job.sequence = File.open(
        File.expand_path("../../data/prot_seqs_lower.txt", __FILE__)
      ).read

      @job.build_gmap_job
      @job.gmap_job.queue       = true
      @job.gmap_job.gmap_dbs    = ["test"]
      @job.gmap_job.prune_level = 0
      @job.gmap_job.splicing    = true
    end

    it "executes gmap on a given dataset and returns an empty report" do
      @job.save!
      @args[:id] = @job.id

      gmap = Quorum::SearchTools::Gmap.new(@args)
      expect {
        gmap.execute_gmap
      }.to_not raise_error

      Dir.glob(
        File.join(@args[:tmp_directory], "*")
      ).length.should be == 0

      log_file = File.join(@args[:log_directory], "quorum.log")

      `tail -n 3 #{log_file}`.to_s.include?("gmap report empty").should be_true
    end
  end
end
