require 'spec_helper'
require 'generators/templates/execute_blast'

describe "ExecuteBlast" do
  describe "simulate executing Blast" do
    before(:each) do
      # Set args as though we executed option_parser.
      @args = {
        :id             => 1,
        :log_directory  => "/path/to/log_directory",
        :tmp            => "/tmp",
        :blast_database => "/path/to/blastdb",
        :blast_threads  => 1,
        :tblastn        => "test",
        :blastp         => "test",
        :blastn         => "test",
        :blastx         => "test",
      }
    end

    it "a stubbed implementation of find_blast_data finds data" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:find_blast_data) do |id, found|
        if id == 1 && found == true
          "Record found."
        elsif id == 2 && found == false
          "Record not found."
        end
      end
      @blast.find_blast_data(1, true).should eq("Record found.")
      @blast.find_blast_data(2, false).should eq("Record not found.")
    end

    it "a stubbed implementation of create_unique_hash does so" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:create_unique_hash) do |seq|
        if seq == "AAAAAAAAAAGGGGGCCCCCTTTTTTTTTT"
          Digest::MD5.hexdigest(seq).to_s + "-" + Time.now.to_i.to_s
        end
      end
      @blast.create_unique_hash("AAAAAAAAAAGGGGGCCCCCTTTTTTTTTT").should eq(
        Digest::MD5.hexdigest("AAAAAAAAAAGGGGGCCCCCTTTTTTTTTT").to_s + 
        "-" + Time.now.to_i.to_s
      )
    end

    it "a stubbed implementation of write_input_sequence_to_file validates " <<
    "sequence and writes to file" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:write_input_sequence_to_file) do |seq, valid|
        if seq == "ACGT" && valid == true 
          "seqret -filter -sformat pearson -osformat fasta < #{seq} > hash.fa"
        elsif seq == "ACGT" && valid == false
          "Input sequence not in FASTA format."
        end
      end
      @blast.write_input_sequence_to_file("ACGT", true).should eq(
        "seqret -filter -sformat pearson -osformat fasta < ACGT > hash.fa"
      )
      @blast.write_input_sequence_to_file("ACGT", false).should eq(
        "Input sequence not in FASTA format."
      )
    end

    it "a stubbed implementation of generate_blast_cmd does so" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:generate_blast_cmd) do |type, blastn, blastx, tblastn, blastp|
        if type == "nucleic_acid" && blastn == true && blastx == true &&
          tblastn == false && blastp == false
          "blastn -db test -query ACGT -outfmt 6 num_threads 1 " <<
          "-evalue 0.5e-10 -out hash.rep & blastx -db test -query ACGT " <<
          "-outfmt 6 -num_threads 1 -evalue 0.5e-20 -out hash.prot"
        elsif type == "nucleic_acid" && blastn == true && blastx == false &&
          tblastn == false && blastp == false
          "blastn -db test -query ACGT -outfmt 6 num_threads 1 " <<
          "-evalue 0.5e-10 -out hash.rep"
        elsif type == "nucleic_acid" && blastn == false && blastx == true &&
          tblastn == false && blastp == false
          "blastx -db test -query ACGT -outfmt 6 -num_threads 1 " <<
          "-evalue 0.5e-20 -out hash.prot"
        elsif type == "amino_acid" && blastn == false && blastx == false && 
          tblastn == true && blastp == true
          "tblastn -db test -query ELVIS -outfmt 6 num_threads 1 " <<
          "-evalue 0.5e-10 -out hash.rep & blastp -db test -query ELVIS " <<
          "-outfmt 6 -num_threads 1 -evalue 0.5e-20 -out hash.prot"
        elsif type == "amino_acid" && blastn == false && blastx == false && 
          tblastn == true && blastp == false
          "tblastn -db test -query ELVIS -outfmt 6 num_threads 1 " <<
          "-evalue 0.5e-10 -out hash.rep"
        elsif type == "amino_acid" && blastn == false && blastx == false && 
          tblastn == false && blastp == true
          "blastp -db test -query ELVIS -outfmt 6 -num_threads 1 " <<
          "-evalue 0.5e-20 -out hash.prot"
        end
      end
      @blast.generate_blast_cmd(
        "nucleic_acid", true, true, false, false
      ).should eq(
        "blastn -db test -query ACGT -outfmt 6 num_threads 1 " <<
        "-evalue 0.5e-10 -out hash.rep & blastx -db test -query ACGT " <<
        "-outfmt 6 -num_threads 1 -evalue 0.5e-20 -out hash.prot"
      )
      @blast.generate_blast_cmd(
        "nucleic_acid", true, false, false, false
      ).should eq(
        "blastn -db test -query ACGT -outfmt 6 num_threads 1 " <<
        "-evalue 0.5e-10 -out hash.rep"
      )
      @blast.generate_blast_cmd(
        "nucleic_acid", false, true, false, false
      ).should eq(
        "blastx -db test -query ACGT -outfmt 6 -num_threads 1 " <<
        "-evalue 0.5e-20 -out hash.prot"
      )
      @blast.generate_blast_cmd(
        "amino_acid", false, false, true, true
      ).should eq(
        "tblastn -db test -query ELVIS -outfmt 6 num_threads 1 " <<
        "-evalue 0.5e-10 -out hash.rep & blastp -db test -query ELVIS " <<
        "-outfmt 6 -num_threads 1 -evalue 0.5e-20 -out hash.prot"
      )
      @blast.generate_blast_cmd(
        "amino_acid", false, false, true, false
      ).should eq(
        "tblastn -db test -query ELVIS -outfmt 6 num_threads 1 " <<
        "-evalue 0.5e-10 -out hash.rep"
      )
      @blast.generate_blast_cmd(
        "amino_acid", false, false, false, true
      ).should eq(
        "blastp -db test -query ELVIS -outfmt 6 -num_threads 1 " <<
        "-evalue 0.5e-20 -out hash.prot"
      )
    end

    it "a stubbed implemenation of remove_files removed tmp files" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:remove_files) do |tmp, hash, found|
        if tmp == "test" && hash == "hash" && found == true
          "rm test/hash*"
        elsif tmp == "test" && hash == "" && found == false
          ""
        end
      end 
      @blast.remove_files("test", "hash", true).should eq(
        "rm test/hash*"
      )
      @blast.remove_files("test", "", false).should eq("")
    end

    it "a stubbed implementation of logger logs data and exits" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:logger) do |program, message, exit_status|
        if program == "Blast" && message == "Oops" && exit_status == 1
          "\nTimestamp Blast\nOops\nexiting"
        elsif program == "Blast" && message == "No biggie" && exit_status == nil
          "\nTimestamp Blast\nNo biggie\n"
        end
      end
      @blast.logger("Blast", "Oops", 1).should eq(
        "\nTimestamp Blast\nOops\nexiting"
      )
      @blast.logger("Blast", "No biggie", nil).should eq(
        "\nTimestamp Blast\nNo biggie\n"
      )
    end

    it "a stubbed implemenation of execute_blast executes system cmd" do
      @blast = Quorum::Blast.new(@args)
      @blast.stub(:execute_blast) do |file_size|
        if file_size > 0
          "Results"
        else
          "Blast report empty"
        end
      end 
      @blast.execute_blast(1).should eq("Results")
      @blast.execute_blast(0).should eq("Blast report empty")
    end

  end
end
