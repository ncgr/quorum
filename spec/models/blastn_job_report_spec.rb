require 'spec_helper'

describe Quorum::BlastnJobReport do

  before(:all) do
    @blastn = Quorum::BlastnJobReport
  end

  it "should respond to default_order" do
    @blastn.respond_to?(:default_order).should be_true
  end

  before(:each) do
    2.times do
      @blastn.create!({
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
        :blastn_job_id => 1
      })
    end
  end

  it "should be searchable" do
    p = { :id => 1, :blastn_id => "1,2", :query => "test" }
    @blastn.search(p).count.should eq(2)

    p = { :id => 1, :blastn_id => "2", :query => "test" }
    @blastn.search(p).count.should eq(1)

    p = { :id => 1, :blastn_id => "1,2", :query => nil }
    @blastn.search(p).count.should eq(2)

    p = { :id => 1, :blastn_id => nil, :query => "test" }
    @blastn.search(p).count.should eq(2)

    p = { :id => 1 }
    @blastn.search(p).count.should eq(2)

    @blastn.search({}).count.should eq(0)
  end

end
