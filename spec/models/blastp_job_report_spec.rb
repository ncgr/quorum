require 'spec_helper'

describe Quorum::BlastpJobReport do

  before(:all) do
    @blastp = Quorum::BlastpJobReport
  end

  it "should respond to default_order" do
    @blastp.respond_to?(:default_order).should be_true
  end

  before(:each) do
    2.times do
      @blastp.create!({
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
        :blastp_job_id => 1
      })
    end
  end

  it "should be searchable" do
    p = { :id => 1, :blastp_id => "1,2", :query => "test" }
    @blastp.search(p).count.should eq(2)

    p = { :id => 1, :blastp_id => "2", :query => "test" }
    @blastp.search(p).count.should eq(1)

    p = { :id => 1, :blastp_id => "1,2", :query => nil }
    @blastp.search(p).count.should eq(2)

    p = { :id => 1, :blastp_id => nil, :query => "test" }
    @blastp.search(p).count.should eq(2)

    p = { :id => 1 }
    @blastp.search(p).count.should eq(2)

    @blastp.search({}).count.should eq(0)
  end

end

