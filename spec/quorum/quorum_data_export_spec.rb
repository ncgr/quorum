require 'spec_helper'
require 'quorum/data_export'

include Quorum::DataExport

describe "Quorum::DataExport" do

  before(:each) do
    @blastn = Quorum::BlastnJobReport
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
        :results => true
      })
    end
  end

  describe "#to_txt" do
    it "returns a tab delimited string of Blast results" do
      @blastn.to_txt.match(/[\w\d\W\t\n]*/).should be_true
    end
  end

  describe "#to_gff" do
    it "returns a gff string of Blast results" do
      @blastn.to_gff.match(/##gff-version 3\n\.*/).should be_true
      # Strand should be +
      @blastn.to_gff.include?("+").should be_true
    end
  end

  describe "#format_hit_start_stop" do
    it "returns original params when start < stop" do
      format_hit_start_stop(10, 12).should eq([10,12])
    end

    it "returns params in acending order when start > stop" do
      format_hit_start_stop(12, 10).should eq([10,12])
    end
  end

end
