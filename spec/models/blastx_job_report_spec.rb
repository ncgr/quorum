require 'spec_helper'

describe Quorum::BlastxJobReport do
  
  it "should respond to default_order" do
    Quorum::BlastxJobReport.methods.should include(:default_order) 
  end

  it "should respond to default_order" do
    Quorum::BlastxJobReport.methods.should include(:by_query) 
  end

end
