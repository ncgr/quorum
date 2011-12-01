require 'spec_helper'

describe Quorum::BlastnJobReport do
  
  it "should respond to default_order" do
    Quorum::BlastnJobReport.methods.should include(:default_order) 
  end

end
