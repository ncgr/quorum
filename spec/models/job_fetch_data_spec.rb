require 'spec_helper'

describe Quorum::JobFetchData do

  before(:each) do
    @fetch = Quorum::JobFetchData.new
  end

  it "validates presence of attributes" do
    @fetch.should have(1).error_on(:algo)
    @fetch.should have(1).error_on(:blast_dbs)
    @fetch.should have(1).error_on(:hit_id)
    @fetch.should have(1).error_on(:hit_display_id)
    @fetch.valid?.should be_false
  end

  it "passes validation when attrs are set" do
    @fetch.algo           = "foo"
    @fetch.blast_dbs      = "foo"
    @fetch.hit_id         = "foo"
    @fetch.hit_display_id = "foo"
    @fetch.valid?.should be_true
  end

end
