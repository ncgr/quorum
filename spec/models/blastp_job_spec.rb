require 'spec_helper'

describe Quorum::BlastpJob do

  before(:each) do
    @blastp_job = Quorum::BlastpJob.new()
  end

  it "fails validation with poorly formatted expectation (using error_on)" do
    @blastp_job.expectation = "this is bad"
    @blastp_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values (using error_on)" do
    @blastp_job.expectation = 12
    @blastp_job.should have(0).errors_on(:expectation)
    @blastp_job.expectation = 12.1201
    @blastp_job.should have(0).errors_on(:expectation)
    @blastp_job.expectation = "12e-10"
    @blastp_job.should have(0).errors_on(:expectation)
    @blastp_job.expectation = "2e+10"
    @blastp_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_score (using error_on)" do
    @blastp_job.max_score = 12.34
    @blastp_job.should have(1).error_on(:max_score)
    @blastp_job.max_score = "not a number"
    @blastp_job.should have(1).error_on(:max_score)
  end

  it "passed validation with valid max_score (using error_on)" do
    @blastp_job.max_score = 1235
    @blastp_job.should have(0).errors_on(:max_score)
  end

  it "fails validation with poorly formatted gap_opening_penalty (using error_on)" do
    @blastp_job.gap_opening_penalty = "not a number"
    @blastp_job.should have(1).error_on(:gap_opening_penalty)
    @blastp_job.gap_opening_penalty = 100.10
    @blastp_job.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty (using error_on)" do
    @blastp_job.max_score = 13
    @blastp_job.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty (using error_on)" do
    @blastp_job.gap_extension_penalty = "who are you?"
    @blastp_job.should have(1).error_on(:gap_extension_penalty)
    @blastp_job.gap_extension_penalty = 0.3
    @blastp_job.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty (using error_on)" do
    @blastp_job.max_score = 456
    @blastp_job.should have(0).errors_on(:gap_extension_penalty)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @blastp_job.gapped_alignments = true
    @blastp_job.gap_opening_extension = ""
    @blastp_job.should have(1).error_on(:gap_opening_extension)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @blastp_job.gapped_alignments = true
    @blastp_job.gap_opening_extension = "11, 2"
    @blastp_job.should have(0).errors_on(:gap_opening_extension)
  end

  it "gapped_alignment? returns true if gapped_alignments is set" do
    @blastp_job.gapped_alignments = true
    @blastp_job.gapped_alignment?.should be_true
  end

  it "gapped_alignment? returns false if gapped_alignments is not set" do
    @blastp_job.gapped_alignments = false
    @blastp_job.gapped_alignment?.should be_false
  end

  it "gap_opening_extension values should return an Array of Arrays" do
    @blastp_job.gap_opening_extension_values.should eq(
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

end
