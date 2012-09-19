require 'spec_helper'

describe Quorum::TblastnJob do

  before(:each) do
    @tblastn_job = Quorum::TblastnJob.new()
  end

  it "fails validation with poorly formatted expectation" do
    @tblastn_job.expectation = "this is bad"
    @tblastn_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values" do
    @tblastn_job.expectation = 12
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = 12.1201
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = "12e-10"
    @tblastn_job.should have(0).errors_on(:expectation)
    @tblastn_job.expectation = "2e+10"
    @tblastn_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_target_seqs" do
    @tblastn_job.max_target_seqs = 12.34
    @tblastn_job.should have(1).error_on(:max_target_seqs)
    @tblastn_job.max_target_seqs = "not a number"
    @tblastn_job.should have(1).error_on(:max_target_seqs)
  end

  it "passed validation with valid max_target_seqs" do
    @tblastn_job.max_target_seqs = 1235
    @tblastn_job.should have(0).errors_on(:max_target_seqs)
  end

  it "fails validation with poorly formatted gap_opening_penalty" do
    @tblastn_job.gap_opening_penalty = "not a number"
    @tblastn_job.should have(1).error_on(:gap_opening_penalty)
    @tblastn_job.gap_opening_penalty = 100.10
    @tblastn_job.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty" do
    @tblastn_job.max_target_seqs = 13
    @tblastn_job.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty" do
    @tblastn_job.gap_extension_penalty = "who are you?"
    @tblastn_job.should have(1).error_on(:gap_extension_penalty)
    @tblastn_job.gap_extension_penalty = 0.3
    @tblastn_job.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty" do
    @tblastn_job.max_target_seqs = 456
    @tblastn_job.should have(0).errors_on(:gap_extension_penalty)
  end

  it "passes validation without selecting gap_opening_extension with gapped_alignment" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gap_opening_extension = ""
    @tblastn_job.should have(0).error_on(:gap_opening_extension)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gap_opening_extension = "11, 2"
    @tblastn_job.should have(0).errors_on(:gap_opening_extension)
  end

  it "gapped_alignment? returns true if gapped_alignments is set" do
    @tblastn_job.gapped_alignments = true
    @tblastn_job.gapped_alignment?.should be_true
  end

  it "gapped_alignment? returns false if gapped_alignments is not set" do
    @tblastn_job.gapped_alignments = false
    @tblastn_job.gapped_alignment?.should be_false
  end

  it "gap_opening_extension values should return an Array of Arrays" do
    @tblastn_job.gap_opening_extension_values.should eq(
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

  it "passes validation if not enqueued and blast_dbs is empty" do
    @tblastn_job.queue = false
    @tblastn_job.blast_dbs = []
    @tblastn_job.should have(0).errors_on(:blast_dbs)
  end

  it "fails validation if blast_dbs is empty" do
    @tblastn_job.queue = true
    @tblastn_job.blast_dbs = []
    @tblastn_job.should have(1).errors_on(:blast_dbs)
  end

  # Test for removal of multiple select hidden field value.
  it "fails validation if blast_dbs contains an empty string" do
    @tblastn_job.queue = true
    @tblastn_job.blast_dbs = ["", "", ""]
    @tblastn_job.should have(1).errors_on(:blast_dbs)
  end

  it "joins blast_dbs on semicolon after save" do
    @tblastn_job.blast_dbs = ["test_1", "test_2"]
    @tblastn_job.save
    @tblastn_job.blast_dbs.should eq("test_1;test_2")
  end

  it "sets optional params to default values if empty after save" do
    @tblastn_job.save
    @tblastn_job.expectation.should eq("5e-20")
    @tblastn_job.max_target_seqs.should eq(25)
    @tblastn_job.min_bit_score.should eq(0)
    @tblastn_job.gap_opening_penalty.should be_nil
    @tblastn_job.gap_extension_penalty.should be_nil
  end

end
