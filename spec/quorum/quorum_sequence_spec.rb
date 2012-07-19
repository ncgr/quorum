require 'spec_helper'
require 'quorum/sequence'

include Quorum::Sequence

describe "Quorum::Sequence" do
  describe "#create_hash" do
    it "creates a MD5.hexdigest of a sequence" do
      sequence = File.open(
        File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      ).read
      create_hash(sequence).should_not be_nil
    end
  end

  describe "#write_input_sequence_to_file" do
    it "writes valid FASTA input sequence to file" do
      sequence = File.open(
        File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      ).read
      dir  = File.join(::Rails.root.to_s, "log")
      hash = create_hash(sequence)
      write_input_sequence_to_file(dir, hash, sequence)

      File.size(
        File.join(dir, hash + ".seq")
      ).should be > 0

      File.size(
        File.join(dir, hash + ".fa")
      ).should be > 0

      `rm #{File.join(dir, hash + "*")}`
    end

    it "raises an exception if seqret's exit status is > 0" do
      sequence = File.open(
        File.expand_path("../../data/seqs_not_fa.txt", __FILE__)
      ).read
      dir  = File.join(::Rails.root.to_s, "log")
      hash = create_hash(sequence)
      lambda {
        write_input_sequence_to_file(dir, hash, sequence)
      }.should raise_error
      `rm #{File.join(dir, hash + "*")}`
    end
  end

  describe "#discover_input_sequence_type" do
    it "should return 'nucleic_acid' when fed uppercase nucleic acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/nucl_seqs_upper.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("nucleic_acid")
    end

    it "should return 'nucleic_acid' when fed lowercase nucleic acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/nucl_seqs_lower.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("nucleic_acid")
    end

    it "should return 'nucleic_acid' when fed mixed case nucleic acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/nucl_seqs_mixed.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("nucleic_acid")
    end

    it "should return 'amino_acid' when fed uppercase amino acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/prot_seqs_upper.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("amino_acid")
    end

    it "should return 'amino_acid' when fed lowercase amino acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/prot_seqs_lower.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("amino_acid")
    end

    it "should return 'amino_acid' when fed mixed case amino acid sequences" do
      sequence = File.open(
        File.expand_path("../../data/prot_seqs_mixed.txt", __FILE__)
      ).read
      discover_input_sequence_type(sequence).should eq("amino_acid")
    end
  end
end
