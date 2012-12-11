require 'spec_helper'

describe Quorum::GmapJobReport do

  before(:all) do
    @gmap = Quorum::GmapJobReport
  end

  it "should respond to default_order" do
    @gmap.respond_to?(:default_order).should be_true
  end

  it "should be searchable" do
    @gmap.respond_to?(:search).should be_true
  end


end
