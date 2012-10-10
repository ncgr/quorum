require 'spec_helper'

describe Quorum::TblastxJobReport do

  before(:all) do
    @tblastx = Quorum::TblastxJobReport
  end

  it "should respond to default_order" do
    @tblastx.respond_to?(:default_order).should be_true
  end

  before(:each) do
    2.times do
      @tblastx.create!({
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
        :results => true,
        :tblastx_job_id => 1
      })
    end
  end

  it "should be searchable" do
    p = { :id => 1, :tblastx_id => "1,2", :query => "test" }
    @tblastx.search(p).count.should eq(2)

    p = { :id => 1, :tblastx_id => "2", :query => "test" }
    @tblastx.search(p).count.should eq(1)

    p = { :id => 1, :tblastx_id => "1,2", :query => nil }
    @tblastx.search(p).count.should eq(2)

    p = { :id => 1, :tblastx_id => nil, :query => "test" }
    @tblastx.search(p).count.should eq(2)

    p = { :id => 1 }
    @tblastx.search(p).count.should eq(2)

    @tblastx.search({}).count.should eq(0)
  end

end
