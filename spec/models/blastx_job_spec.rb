require 'spec_helper'

describe Quorum::BlastxJob do

  before(:each) do
    @blastx_job = Quorum::BlastxJob.new()
  end

  it "fails validation with poorly formatted expectation" do
    @blastx_job.expectation = "this is bad"
    @blastx_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values" do
    @blastx_job.expectation = 12
    @blastx_job.should have(0).errors_on(:expectation)
    @blastx_job.expectation = 12.1201
    @blastx_job.should have(0).errors_on(:expectation)
    @blastx_job.expectation = "12e-10"
    @blastx_job.should have(0).errors_on(:expectation)
    @blastx_job.expectation = "2e+10"
    @blastx_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_target_seqs" do
    @blastx_job.max_target_seqs = 12.34
    @blastx_job.should have(1).error_on(:max_target_seqs)
    @blastx_job.max_target_seqs = "not a number"
    @blastx_job.should have(1).error_on(:max_target_seqs)
  end

  it "passed validation with valid max_target_seqs" do
    @blastx_job.max_target_seqs = 1235
    @blastx_job.should have(0).errors_on(:max_target_seqs)
  end

  it "fails validation with poorly formatted gap_opening_penalty" do
    @blastx_job.gap_opening_penalty = "not a number"
    @blastx_job.should have(1).error_on(:gap_opening_penalty)
    @blastx_job.gap_opening_penalty = 100.10
    @blastx_job.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty" do
    @blastx_job.max_target_seqs = 13
    @blastx_job.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty" do
    @blastx_job.gap_extension_penalty = "who are you?"
    @blastx_job.should have(1).error_on(:gap_extension_penalty)
    @blastx_job.gap_extension_penalty = 0.3
    @blastx_job.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty" do
    @blastx_job.max_target_seqs = 456
    @blastx_job.should have(0).errors_on(:gap_extension_penalty)
  end

  it "passes validation without selecting gap_opening_extension with gapped_alignment" do
    @blastx_job.gapped_alignments = true
    @blastx_job.gap_opening_extension = ""
    @blastx_job.should have(0).error_on(:gap_opening_extension)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment" do
    @blastx_job.gapped_alignments = true
    @blastx_job.gap_opening_extension = "11, 2"
    @blastx_job.should have(0).errors_on(:gap_opening_extension)
  end

  it "gapped_alignment? returns true if gapped_alignments is set" do
    @blastx_job.gapped_alignments = true
    @blastx_job.gapped_alignment?.should be_true
  end

  it "gapped_alignment? returns false if gapped_alignments is not set" do
    @blastx_job.gapped_alignments = false
    @blastx_job.gapped_alignment?.should be_false
  end

  it "gap_opening_extension values should return an Array of Arrays" do
    @blastx_job.gap_opening_extension_values.should eq(
      [
        ['--Select--', ''],
        ['32767, 32767', '32767,32767'],
        ['11, 2', '11,2'],
        ['10, 2', '10,2'],
        ['9, 2', '9,2'],
        ['8, 2', '8,2'],
        ['7, 2', '7,2'],
        ['6, 2', '6,2'],
        ['13, 1', '13,1'],
        ['12, 1', '12,1'],
        ['11, 1', '11,1'],
        ['10, 1', '10,1'],
        ['9, 1', '9,1']
      ]
    )
  end

  it "joins blast_dbs on semicolon after save" do
    @blastx_job.blast_dbs = ["test_1", "test_2"]
    @blastx_job.save
    @blastx_job.blast_dbs.should eq("test_1;test_2")
  end

  it "sets optional params to default values if empty after save" do
    @blastx_job.save
    @blastx_job.expectation.should eq("5e-20")
    @blastx_job.max_target_seqs.should eq(25)
    @blastx_job.min_bit_score.should eq(0)
    @blastx_job.gap_opening_penalty.should be_nil
    @blastx_job.gap_extension_penalty.should be_nil
  end

end
