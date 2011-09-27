require 'spec_helper'
require 'tasks/lib/build_blast_db'

describe "blastdb rake tasks", :focus do

  describe "simulate rake quorum:blastdb:build" do
    before(:each) do
      # Set args as though we executed the rake task.
      @args = {
        :dir => File.expand_path("../../dummy/quorum/blastdb/tmp",
                                 __FILE__),

        :type        => "both",
        :prot_file   => "peptides.fa",
        :nucl_file   => "contigs.fa",
        :rebuild_db  => true,

        :blastdb_dir => File.expand_path("../../data/blastdb", __FILE__),

        :gff_dir => File.expand_path("../../data/gff", __FILE__),
        :log_dir => File.expand_path("../../data/log", __FILE__)
      }
      # Handled in rake task.
      @args[:dir] = @args[:dir].split(':')
    end
    
    it "raises exception without DIR argument" do
      expect {
        Quorum::BuildBlastDB.new({}).build_blast_db_data
      }.to raise_error(
        RuntimeError, 
        'DIR must be set to continue. Execute `rake -D` for more information.'
      )
    end

    it "raises exception with unknow TYPE" do
      @args[:type] = "unknown"
      expect {
        Quorum::BuildBlastDB.new(@args).build_blast_db_data
      }.to raise_error(
        RuntimeError, 
        "Unknown type: #{@args[:type]}. Please provide one: both, nucl or prot."
      )
    end

    it "raise exception with unknown directory" do
      @args[:dir] = ["foo_bar_baz"]
      @build = Quorum::BuildBlastDB.new(@args)
      expect {
        @build.build_blast_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Directory not found: foo_bar_baz"
      )
    end

    it "raise exception without correct data directory" do
      @args[:dir] = [File.dirname( __FILE__)]
      @build = Quorum::BuildBlastDB.new(@args)
      expect {
        @build.build_blast_db_data
        @build.stub(:check_dependencies)
        @build.stub(:make_directories)
      }.to raise_error(
        RuntimeError,
        "Data not found. Please check your directory and try again.\n" <<
        "Directory Entered: #{File.dirname(__FILE__)}"
      )
    end

    it "a stubbed implementation of build_blast_db_data sets files and flag " do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:build_blast_db_data) do |arg|
        if arg =~ Quorum::BuildBlastDB::GZIP
          "files,z"
        elsif arg =~ Quorum::BuildBlastDB::BZIP
          "files,j"
        end
      end
      @build.build_blast_db_data("test.tar.gz").should eq("files,z")
      @build.build_blast_db_data("test.tgz").should eq("files,z")
      @build.build_blast_db_data("test.tar.bz2").should eq("files,j")
      @build.build_blast_db_data("test.tbz").should eq("files,j")
    end

  end

end

