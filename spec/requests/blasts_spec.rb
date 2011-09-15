require 'spec_helper'

describe "Blasts" do
  describe "GET /" do
    it "redirects to new" do
      visit blasts_path
      current_path.should eq(new_blast_path)
    end
  end

  describe "" do

  end
end
