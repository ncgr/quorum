require 'spec_helper'

describe Quorum::JobData do

  before(:each) do
    @job_data = Quorum::JobData.new()
  end

  it "stores data in an array" do
    @job_data.values.should be_a(Array)
  end

  it "#no_results returns a hash { results: false }" do
    @job_data.no_results.should eq([{ results: false }])
  end

  it "#not_enqueued returns a hash { results: false, enqueued: false }" do
    @job_data.not_enqueued.should eq([{ results: false, enqueued: false }])
  end

end
