require 'spec_helper'

describe Quorum::TblastnJobReport do
  
  it "should respond to default_order" do
    Quorum::TblastnJobReport.methods.should include(:default_order) 
  end

end
