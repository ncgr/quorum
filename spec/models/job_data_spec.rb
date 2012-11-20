require 'spec_helper'

describe Quorum::JobData do

  before(:each) do
    @data = Quorum::JobData.new()
  end

  it "#results stores data in an array" do
    @data.results.should be_a(Array)
  end

  it "#no_results returns a hash { results: false }" do
    @data.no_results.should eq([{ results: false }])
  end

  it "#not_enqueued returns a hash { results: false, enqueued: false }" do
    @data.not_enqueued.should eq([{ results: false, enqueued: false }])
  end

end
