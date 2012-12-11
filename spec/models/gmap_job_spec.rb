require 'spec_helper'

describe Quorum::GmapJob do

  before(:each) do
    @gmap_job = Quorum::GmapJob.new()
  end

  it "fails validation when passed floating point numbers" do
    @gmap_job.intron_len = 0.1
    @gmap_job.should have(1).error_on(:intron_len)
    @gmap_job.total_len = 10.1
    @gmap_job.should have(1).error_on(:total_len)
    @gmap_job.chimera_margin = 100.1
    @gmap_job.should have(1).error_on(:chimera_margin)
  end

  it "passes validation when passed integers" do
    @gmap_job.intron_len = 1
    @gmap_job.should have(0).error_on(:intron_len)
    @gmap_job.total_len = 10
    @gmap_job.should have(0).error_on(:total_len)
    @gmap_job.chimera_margin = 100
    @gmap_job.should have(0).error_on(:chimera_margin)
  end

  it "passes validation if not enqueued and gmap_dbs is empty" do
    @gmap_job.queue = false
    @gmap_job.gmap_dbs = []
    @gmap_job.should have(0).errors_on(:gmap_dbs)
  end

  it "fails validation if gmap_dbs is empty" do
    @gmap_job.queue = true
    @gmap_job.gmap_dbs = []
    @gmap_job.should have(1).errors_on(:gmap_dbs)
  end

  # Test for removal of multiple select hidden field value.
  it "fails validation if gmap_dbs contains an empty string" do
    @gmap_job.queue = true
    @gmap_job.gmap_dbs = ["", "", ""]
    @gmap_job.should have(1).errors_on(:gmap_dbs)
  end

  it "joins gmap_dbs on semicolon after save" do
    @gmap_job.gmap_dbs = ["test_1", "test_2"]
    @gmap_job.save
    @gmap_job.gmap_dbs.should eq("test_1;test_2")
  end

  it "sets optional params to default values if empty after save" do
    @gmap_job.save
    @gmap_job.chimera_margin.should eq(40)
  end

  it "checks for splicing and sets intron / total length" do
    @gmap_job.splicing = true
    @gmap_job.save
    @gmap_job.intron_len.should eq(Quorum.gmap_max_internal_intron_len)
    @gmap_job.total_len.should eq(Quorum.gmap_max_total_intron_len)

    @gmap_job.splicing = false
    @gmap_job.save
    @gmap_job.intron_len.should be_nil
    @gmap_job.total_len.should be_nil
  end

end
