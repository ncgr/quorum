require 'spec_helper'

describe Quorum::TblastxJobReport do

  it "should respond to default_order" do
    Quorum::TblastxJobReport.methods.should include(:default_order)
  end

  it "should respond to default_order" do
    Quorum::TblastxJobReport.methods.should include(:by_query)
  end

end
