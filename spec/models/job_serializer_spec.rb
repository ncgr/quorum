require 'spec_helper'

describe "Quorum::JobSerializer" do

  include Quorum::JobSerializer
  before(:each) do
    @blastn = Quorum::BlastnJobReport
    2.times do
      @blastn.create!({
        :query => "test",
        :hit_display_id => "foo",
        :identity => 0,
        :align_len => 0,
        :pct_identity => 100.0,
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

  describe "#as_json" do
    it "returns error messages as json when present" do
      Quorum::JobSerializer.as_json(Quorum::Job.create({})).should have_key(:errors)
    end

    it "returns object as json" do
      Quorum::JobSerializer.as_json(@blastn.first).should eq(@blastn.first.as_json)
    end
  end

  describe "#as_txt" do
    it "returns a tab delimited string of Blast results" do
      Quorum::JobSerializer.as_txt(@blastn.all).match(/[\w\d\W\t\n]*/).should be_true
    end
  end

  describe "#as_gff" do
    it "returns a gff string of Blast results" do
      Quorum::JobSerializer.as_gff(@blastn.all).match(/##gff-version 3\n\.*/).should be_true
      # Strand should be +
      Quorum::JobSerializer.as_gff(@blastn.all).include?("+").should be_true
    end
  end

  describe "#format_hit_start_stop" do
    it "returns original params when start < stop" do
      Quorum::JobSerializer.format_hit_start_stop(10, 12).should eq([10,12])
    end

    it "returns params in acending order when start > stop" do
      Quorum::JobSerializer.format_hit_start_stop(12, 10).should eq([10,12])
    end
  end

end
