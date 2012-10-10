require 'spec_helper'

describe Quorum::TblastxJob do

  before(:each) do
    @tblastx_job = Quorum::TblastxJob.new()
  end

  it "fails validation with poorly formatted expectation" do
    @tblastx_job.expectation = "this is bad"
    @tblastx_job.should have(1).error_on(:expectation)
  end

  it "passes validation with valid expectation values" do
    @tblastx_job.expectation = 12
    @tblastx_job.should have(0).errors_on(:expectation)
    @tblastx_job.expectation = 12.1201
    @tblastx_job.should have(0).errors_on(:expectation)
    @tblastx_job.expectation = "12e-10"
    @tblastx_job.should have(0).errors_on(:expectation)
    @tblastx_job.expectation = "2e+10"
    @tblastx_job.should have(0).errors_on(:expectation)
  end

  it "fails validation with poorly formatted max_target_seqs" do
    @tblastx_job.max_target_seqs = 12.34
    @tblastx_job.should have(1).error_on(:max_target_seqs)
    @tblastx_job.max_target_seqs = "not a number"
    @tblastx_job.should have(1).error_on(:max_target_seqs)
  end

  it "passed validation with valid max_target_seqs" do
    @tblastx_job.max_target_seqs = 1235
    @tblastx_job.should have(0).errors_on(:max_target_seqs)
  end

  it "passes validation if not enqueued and blast_dbs is empty" do
    @tblastx_job.queue = false
    @tblastx_job.blast_dbs = []
    @tblastx_job.should have(0).errors_on(:blast_dbs)
  end

  it "fails validation if blast_dbs is empty" do
    @tblastx_job.queue = true
    @tblastx_job.blast_dbs = []
    @tblastx_job.should have(1).errors_on(:blast_dbs)
  end

  # Test for removal of multiple select hidden field value.
  it "fails validation if blast_dbs contains an empty string" do
    @tblastx_job.queue = true
    @tblastx_job.blast_dbs = ["", "", ""]
    @tblastx_job.should have(1).errors_on(:blast_dbs)
  end

  it "joins blast_dbs on semicolon after save" do
    @tblastx_job.blast_dbs = ["test_1", "test_2"]
    @tblastx_job.save
    @tblastx_job.blast_dbs.should eq("test_1;test_2")
  end

  it "sets optional params to default values if empty after save" do
    @tblastx_job.save
    @tblastx_job.expectation.should eq("5e-20")
    @tblastx_job.max_target_seqs.should eq(25)
    @tblastx_job.min_bit_score.should eq(0)
  end

end
