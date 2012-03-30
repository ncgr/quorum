require 'spec_helper'

describe Quorum::TblastnJobReport do

  it "should respond to default_order" do
    Quorum::TblastnJobReport.methods.should include(:default_order)
  end

  it "should respond to default_order" do
    Quorum::TblastnJobReport.methods.should include(:by_query)
  end

end
