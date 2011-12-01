require 'spec_helper'

describe Quorum::BlastpJobReport do
  
  it "should respond to default_order" do
    Quorum::BlastpJobReport.methods.should include(:default_order) 
  end

end
