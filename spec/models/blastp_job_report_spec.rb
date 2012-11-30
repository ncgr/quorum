require 'spec_helper'

describe Quorum::BlastpJobReport do

  before(:all) do
    @blastp = Quorum::BlastpJobReport
  end

  it "should respond to default_order" do
    @blastp.respond_to?(:default_order).should be_true
  end

  it "should be searchable" do
    @blastp.respond_to?(:search).should be_true
  end

end

