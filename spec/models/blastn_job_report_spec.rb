require 'spec_helper'

describe Quorum::BlastnJobReport do

  before(:all) do
    @blastn = Quorum::BlastnJobReport
  end

  it "should respond to default_order" do
    @blastn.respond_to?(:default_order).should be_true
  end

  it "should be searchable" do
    @blastn.respond_to?(:search).should be_true
  end

end
