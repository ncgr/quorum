require 'spec_helper'

describe Quorum::TblastnJobReport do

  before(:all) do
    @tblastn = Quorum::TblastnJobReport
  end

  it "should respond to default_order" do
    @tblastn.respond_to?(:default_order).should be_true
  end

  it "should be searchable" do
    @tblastn.respond_to?(:search).should be_true
  end

end

