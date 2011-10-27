require 'spec_helper'
require 'generators/templates/sequence'

include Quorum::Utils::Sequence

describe "Quorum::Utils::Sequence" do
  describe "#create_unique_hash" do
    it "creates a MD5.hexdigest of a sequence" do
      sequence = File.open(
        File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      ).read
      create_unique_hash(sequence).should_not be_nil 
    end
  end

  describe "#write_input_sequence_to_file" do
    it "writes valid FASTA input sequence to file" do
      sequence = File.open(
        File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      ).read
      dir  = File.join(::Rails.root.to_s, "log")
      hash = create_unique_hash(sequence)
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
        File.expand_path("../../data/nucl_seqs_not_fa.txt", __FILE__)
      ).read
      dir  = File.join(::Rails.root.to_s, "log")
      hash = create_unique_hash(sequence)
      lambda {
        write_input_sequence_to_file(dir, hash, sequence)
      }.should raise_error
      `rm #{File.join(dir, hash + "*")}`
    end
  end

  describe "#discover_input_sequence_type" do
    it "should return 'nucleic_acid' when fed nucleic acid sequences" do
      sequence = File.expand_path("../../data/nucl_seqs.txt", __FILE__)
      discover_input_sequence_type(sequence).should eq("nucleic_acid")
    end

    it "should return 'amino_acid' when fed amino acid sequences" do
      sequence = File.expand_path("../../data/prot_seqs.txt", __FILE__)
      discover_input_sequence_type(sequence).should eq("amino_acid")
    end
  end
end
