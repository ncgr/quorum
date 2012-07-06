require 'spec_helper'

describe Quorum::TblastnJobReport do

  before(:all) do
    @tblastn = Quorum::TblastnJobReport
  end

  it "should respond to default_order" do
    @tblastn.methods.should include(:default_order)
    @tblastn.respond_to?(:default_order).should be_true
  end

  it "should respond to to_txt and to_gff" do
    @tblastn.respond_to?(:to_txt).should be_true
    @tblastn.respond_to?(:to_gff).should be_true
  end

  before(:each) do
    2.times do
      @tblastn.create!({
        :query => "test",
        :hit_display_id => "foo",
        :identity => 0,
        :align_len => 0,
        :query_from => 10,
        :query_to => 100,
        :hit_from => 900,
        :hit_to => 1000,
        :evalue => "1e-100",
        :bit_score => 1000,
        :results => true
      })
    end
  end

  it "should be searchable" do
    p = { :algo_id => "1,2", :query => "test" }
    @tblastn.search(p).count.should eq(2)

    p = { :algo_id => "2", :query => "test" }
    @tblastn.search(p).count.should eq(1)

    p = { :algo_id => "1,2", :query => nil }
    @tblastn.search(p).count.should eq(2)

    p = { :algo_id => nil, :query => "test" }
    @tblastn.search(p).count.should eq(2)

    @tblastn.search({}).count.should eq(2)
  end

  it "should be exportable as txt and gff" do
    @tblastn.to_txt.should match(/[a-zA-Z0-9\t\n]+/)
    @tblastn.to_gff.should match(/##gff-version 3\n\.*/)
  end

end

