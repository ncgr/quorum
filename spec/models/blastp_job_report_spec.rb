require 'spec_helper'

describe Quorum::BlastpJobReport do

  it "should respond to default_order" do
    Quorum::BlastpJobReport.methods.should include(:default_order)
  end

  it "should respond to by_query" do
    Quorum::BlastpJobReport.methods.should include(:by_query)
  end

end
