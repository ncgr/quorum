require 'spec_helper'
require 'tasks/lib/build_blast_db'

describe "blastdb rake tasks" do
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

    it "a stubbed implementation of check_dependencies does so" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:check_dependencies) do |arg, found|
        if arg == "rails" && found == true
          "which rails >& /dev/null"
        elsif arg == "unknown" && found == false
          "Dependency not found. Please add `unknown` to your PATH."
        end
      end
      @build.check_dependencies("rails", true).should eq(
        "which rails >& /dev/null"
      )
      @build.check_dependencies("unknown", false).should eq(
        "Dependency not found. Please add `unknown` to your PATH."
      )
    end

    it "a stubbed implementation of make_directories manages directories" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:make_directories) do |dir, exists, rebuild|
        if dir == "blastdb" && exists == false && rebuild == true
          "mkdir blastdb"
        elsif dir == "blastdb" && exists == false && rebuild == false
          "mkdir blastdb"
        elsif dir == "gff" && exists == true && rebuild == true
          "rm -rf gff; mkdir gff"
        elsif dir == "gff" && exists == true && rebuild == false
          ""
        else
          "Unable to make directory. Perhaps you forgot to execute the " <<
          "quorum initializer. \n\nrails generate quorum:install"
        end
      end
      @build.make_directories("blastdb", false, true).should eq(
        "mkdir blastdb"
      )
      @build.make_directories("blastdb", false, false).should eq(
        "mkdir blastdb"
      )
      @build.make_directories("gff", true, true).should eq(
        "rm -rf gff; mkdir gff"
      )
      @build.make_directories("gff", true, false).should eq(
        ""
      )
      @build.make_directories("unknown", true, true).should eq(
        "Unable to make directory. Perhaps you forgot to execute the " <<
        "quorum initializer. \n\nrails generate quorum:install"
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

    it "a stubbed implementation of extract_files executes a tar cmd" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:extract_files) do |src, file, flag, path|
        if src == "tarball.tgz" && file == "contigs.fa" && flag == "z" && 
          path == "/path/to/tarball.tgz"
          "tar -x#{flag}Of #{src} #{file} >> #{path} 2>> " <<
          "extract_data_error.log"
        elsif src == "tarball.tbz" && file == "peptides.fa" && flag == "j" && 
          path == "/path/to/tarball.tbz"
          "tar -x#{flag}Of #{src} #{file} >> #{path} 2>> " << 
          "extract_data_error.log"
        else
          "Data extraction error. See extract_data_error.log for details."
        end
      end
      @build.extract_files(
        "tarball.tgz", "contigs.fa", "z", "/path/to/tarball.tgz"
      ).should eq(
      "tar -xzOf tarball.tgz contigs.fa >> /path/to/tarball.tgz 2>> " <<
      "extract_data_error.log"
      )

      @build.extract_files(
        "tarball.tbz", "peptides.fa", "j", "/path/to/tarball.tbz"
      ).should eq(
      "tar -xjOf tarball.tbz peptides.fa >> /path/to/tarball.tbz 2>> " <<
      "extract_data_error.log"
      )

      @build.extract_files("", "", "", "").should eq(
      "Data extraction error. See extract_data_error.log for details."
      )
    end

    it "a stubbed implementation of build_blast_db calls execute_makeblastdb" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:build_blast_db) do |blastdb, title, type, found|
        if blastdb == "blastdb" && title == "test" && type == "contigs" &&
          found == true
          "execute_makeblastdb('nucl', test, contigs)"
        elsif blastdb == "blastdb" && title == "test" && 
          type == "peptides" && found == true
          "execute_makeblastdb('prot', test, peptides)"
        elsif blastdb == "blastdb" && title == "test" &&
          type == "contigs" && found == false
          "Extracted data not found for contigs or peptides. " <<
          "Make sure you supplied the correct data directory and file names."
        end
      end 
      @build.build_blast_db("blastdb", "test", "contigs", true).should eq(
        "execute_makeblastdb('nucl', test, contigs)"
      )
      @build.build_blast_db("blastdb", "test", "peptides", true).should eq(
        "execute_makeblastdb('prot', test, peptides)"
      )
      @build.build_blast_db("blastdb", "test", "contigs", false).should eq(
        "Extracted data not found for contigs or peptides. " <<
        "Make sure you supplied the correct data directory and file names."
      )
    end

    it "a stubbed implementation of execute_makeblastdb builds a blast db" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:execute_makeblastdb) do |type, title, input|
        if type == "nucl" && title == "test" && input == "contigs.fa"
          "makeblastdb -dbtype nucl -title test -in contigs.fa -out test " <<
          "-hash_index >> makeblastdb.log"
        elsif type == "prot" && title == "test" && input == "peptides.fa"
          "makeblastdb -dbtype prot -title test -in peptides.fa -out test " <<
          "-hash_index >> makeblastdb.log"
        elsif type == "nucl" && title == "test" && input == "bad_input.txt"
          "makeblastdb error. See makeblastdb.log for details."
        end
      end
      @build.execute_makeblastdb("nucl", "test", "contigs.fa").should eq(
        "makeblastdb -dbtype nucl -title test -in contigs.fa -out test " <<
        "-hash_index >> makeblastdb.log"
      )
      @build.execute_makeblastdb("prot", "test", "peptides.fa").should eq(
        "makeblastdb -dbtype prot -title test -in peptides.fa -out test " <<
        "-hash_index >> makeblastdb.log"
      )
      @build.execute_makeblastdb("nucl", "test", "bad_input.txt").should eq(
        "makeblastdb error. See makeblastdb.log for details."
      )
    end

    it "a stubbed implementation of readme prints file contents" do
      @build = Quorum::BuildBlastDB.new(@args)
      @build.stub(:readme) do |file|
        if file == "readme"
          "print readme"
        else
          "file not found"
        end
      end
      @build.readme("readme").should eq("print readme")
      @build.readme("bad_file").should eq("file not found")
    end

  end
end

