require 'spec_helper'

describe Quorum::BlastnJobReport do

  it "should respond to default_order" do
    Quorum::BlastnJobReport.methods.should include(:default_order)
  end

  it "should respond to by_query" do
    Quorum::BlastnJobReport.methods.should include(:by_query)
  end

end
