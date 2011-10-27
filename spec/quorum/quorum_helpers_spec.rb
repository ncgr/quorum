require 'spec_helper'
require 'quorum/helpers'

include Quorum::Helpers

describe "Quorum::Helpers" do
  describe "#check_kaminari_sort" do
    before(:all) do
      class Klass
        DEFAULT_ORDER    = "default_order"
        SORTABLE_COLUMNS = ["column"]
      end
    end

    it "returns Klass::DEFAULT_ORDER when column and dir are nil" do
      check_kaminari_sort(Klass).should eq("default_order")
    end

    it "returns Klass::DEFAULT_ORDER when column is not sortable" do
      check_kaminari_sort(Klass, "not_a_column").should eq("default_order")
    end

    it "returns an ActiveRecord order with valid column" do
      check_kaminari_sort(Klass, "column").should eq("column desc")
    end

    it "returns an ActiveRecord order with valid column and direction DESC" do
      check_kaminari_sort(Klass, "column", "desc").should eq("column desc")
    end

    it "returns an ActiveRecord order with valid column and direction ASC" do
      check_kaminari_sort(Klass, "column", "asc").should eq("column asc")
    end
  end
end

