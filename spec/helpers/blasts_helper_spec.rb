require "spec_helper"

describe Quorum::BlastsHelper do
  describe "#kaminari_sort_by" do

    it "raises ArgumentError with invalid arguments" do
      lambda {
        helper.kaminari_sort_by(:quorum_path, 12)
      }.should raise_error(ArgumentError)
    end

    it "returns a link without an arrow image with valid arguments" do
      params = {
        :page => 1
      }
      helper.stub!(:params).and_return {params}
      helper.kaminari_sort_by(:quorum_path, "Sort Me").should eq(
        %Q(<a href="/quorum?dir=asc&amp;page=1&amp;sort=sort_me">Sort Me</a>)
      )
    end

    it "returns a link with an arrow image with valid arguments DESC" do
      params = {
        :dir  => "desc",
        :sort => "sort_me",
        :page => 1
      }
      helper.stub!(:params).and_return {params}
      helper.kaminari_sort_by(:quorum_path, "Sort Me").should eq(
        %Q(<a href="/quorum?dir=asc&amp;page=1&amp;sort=sort_me">Sort Me<img alt="Desc_arrow" src="/assets/quorum/desc_arrow.png" /></a>)
      )
    end

    it "returns a link with an arrow image with valid arguments ASC" do
      params = {
        :dir  => "asc",
        :sort => "sort_me",
        :page => 2
      }
      helper.stub!(:params).and_return {params}
      helper.kaminari_sort_by(:quorum_path, "Sort Me").should eq(
        %Q(<a href="/quorum?dir=desc&amp;page=2&amp;sort=sort_me">Sort Me<img alt="Asc_arrow" src="/assets/quorum/asc_arrow.png" /></a>)
      )
    end

  end
end
