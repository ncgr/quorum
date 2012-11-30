require 'spec_helper'

describe Quorum::JobReportSearcher do

  include Quorum::JobReportSearcher

  before(:each) do
    @algo  = "blastn"
    blastn = Quorum::BlastnJobReport
    2.times do
      blastn.create!({
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

  it "makes job reports searchable" do
    p = { :id => 1, :blastn_id => "1,2", :query => "test" }
    search(@algo, p).count.should eq(2)

    p = { :id => 1, :blastn_id => "2", :query => "test" }
    search(@algo, p).count.should eq(1)

    p = { :id => 1, :blastn_id => "1,2", :query => nil }
    search(@algo, p).count.should eq(2)

    p = { :id => 1, :blastn_id => nil, :query => "test" }
    search(@algo, p).count.should eq(2)

    p = { :id => 1 }
    search(@algo, p).count.should eq(2)

    search(@algo, {}).count.should eq(0)
  end

end
