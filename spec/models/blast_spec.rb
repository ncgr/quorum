require 'spec_helper'

describe Quorum::Blast do
  
  before(:each) do
    @blast = Quorum::Blast.new()
  end

  it "fails validation without params (using error_on)" do
    @blast.should have(1).error_on(:sequence_type)
    @blast.should have(1).error_on(:sequence)
  end

  it "fails validation with poorly formatted expectation (using error_on)" do
    @blast.expectation = "this is bad"
    @blast.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values (using error_on)" do
    @blast.expectation = 12
    @blast.should have(0).errors_on(:expectation)
    @blast.expectation = 12.1201
    @blast.should have(0).errors_on(:expectation)
    @blast.expectation = "12e-10"
    @blast.should have(0).errors_on(:expectation)
    @blast.expectation = "2e+10"
    @blast.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_score (using error_on)" do
    @blast.max_score = 12.34
    @blast.should have(1).error_on(:max_score)
    @blast.max_score = "not a number"
    @blast.should have(1).error_on(:max_score)
  end

  it "passed validation with valid max_score (using error_on)" do
    @blast.max_score = 1235
    @blast.should have(0).errors_on(:max_score)
  end

  it "fails validation with poorly formatted gap_opening_penalty (using error_on)" do
    @blast.gap_opening_penalty = "not a number"
    @blast.should have(1).error_on(:gap_opening_penalty)
    @blast.gap_opening_penalty = 100.10
    @blast.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty (using error_on)" do
    @blast.max_score = 13
    @blast.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty (using error_on)" do
    @blast.gap_extension_penalty = "who are you?"
    @blast.should have(1).error_on(:gap_extension_penalty)
    @blast.gap_extension_penalty = 0.3
    @blast.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty (using error_on)" do
    @blast.max_score = 456
    @blast.should have(0).errors_on(:gap_extension_penalty)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @blast.gapped_alignments = true
    @blast.gap_opening_extension = ""
    @blast.should have(1).error_on(:gap_opening_extension)
  end

  it "fails validation without selecting gap_opening_extension with gapped_alignment (using error_on)" do
    @blast.gapped_alignments = true
    @blast.gap_opening_extension = "11, 2"
    @blast.should have(0).errors_on(:gap_opening_extension)
  end

  it "gapped_alignment? returns true if gapped_alignments is set" do
    @blast.gapped_alignments = true
    @blast.gapped_alignment?.should be_true
  end

  it "gapped_alignment? returns false if gapped_alignments is not set" do
    @blast.gapped_alignments = false
    @blast.gapped_alignment?.should be_false
  end

  it "gap_opening_extension values should return an Array of Arrays" do
    @blast.gap_opening_extension_values.should eq(
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
