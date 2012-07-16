require 'spec_helper'

describe Quorum::BlastxJobReport do

  before(:all) do
    @blastx = Quorum::BlastxJobReport
  end

  it "should respond to default_order" do
    @blastx.respond_to?(:default_order).should be_true
  end

  before(:each) do
    2.times do
      @blastx.create!({
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
        :blastx_job_id => 1
      })
    end
  end

  it "should be searchable" do
    p = { :id => 1, :blastx_id => "1,2", :query => "test" }
    @blastx.search(p).count.should eq(2)

    p = { :id => 1, :blastx_id => "2", :query => "test" }
    @blastx.search(p).count.should eq(1)

    p = { :id => 1, :blastx_id => "1,2", :query => nil }
    @blastx.search(p).count.should eq(2)

    p = { :id => 1, :blastx_id => nil, :query => "test" }
    @blastx.search(p).count.should eq(2)

    p = { :id => 1 }
    @blastx.search(p).count.should eq(2)

    @blastx.search({}).count.should eq(0)
  end

end

