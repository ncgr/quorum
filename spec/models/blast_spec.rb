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
  end

  it "passed validation with valid max_score (using error_on)" do
    @blast.max_score = 1235
    @blast.should have(0).errors_on(:max_score)
  end

  it "fails validation with poorly formatted gap_opening_penalty (using error_on)" do
    @blast.gap_opening_penalty = "not a number"
    @blast.should have(1).error_on(:gap_opening_penalty)
  end

  it "passed validation with valid gap_opening_penalty (using error_on)" do
    @blast.max_score = 13
    @blast.should have(0).errors_on(:gap_opening_penalty)
  end

  it "fails validation with poorly formatted gap_extension_penalty (using error_on)" do
    @blast.gap_extension_penalty = "who are you?"
    @blast.should have(1).error_on(:gap_extension_penalty)
  end

  it "passed validation with valid gap_extension_penalty (using error_on)" do
    @blast.max_score = 456
    @blast.should have(0).errors_on(:gap_extension_penalty)
  end

end
