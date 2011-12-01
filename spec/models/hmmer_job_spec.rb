require 'spec_helper'

describe Quorum::HmmerJob do

  before(:each) do
    @hmmer_job = Quorum::HmmerJob.new()
  end

  it "fails validation with poorly formatted expectation (using error_on)" do
    @hmmer_job.expectation = "this is bad"
    @hmmer_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values (using error_on)" do
    @hmmer_job.expectation = 12
    @hmmer_job.should have(0).errors_on(:expectation)
    @hmmer_job.expectation = 12.1201
    @hmmer_job.should have(0).errors_on(:expectation)
    @hmmer_job.expectation = "12e-10"
    @hmmer_job.should have(0).errors_on(:expectation)
    @hmmer_job.expectation = "2e+10"
    @hmmer_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted min_score (using error_on)" do
    @hmmer_job.min_score = 12.34
    @hmmer_job.should have(1).error_on(:min_score)
    @hmmer_job.min_score = "not a number"
    @hmmer_job.should have(1).error_on(:min_score)
  end

  it "passed validation with valid min_score (using error_on)" do
    @hmmer_job.min_score = 1235
    @hmmer_job.should have(0).errors_on(:min_score)
  end

end
