require 'spec_helper'

describe Quorum::BlastxJobReport do

  before(:all) do
    @blastx = Quorum::BlastxJobReport
  end

  it "should respond to default_order" do
    @blastx.respond_to?(:default_order).should be_true
  end

  it "should be searchable" do
    @blastx.respond_to?(:search).should be_true
  end

end

