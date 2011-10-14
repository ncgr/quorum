require 'spec_helper'

describe Quorum::BlastReport do
  
  it "contains sortable columns" do
    Quorum::BlastReport::SORTABLE_COLUMNS.should eq(
      ["query", "bit_score", "hit_len"]
    )
  end

  it "has a default sort order" do
    Quorum::BlastReport::DEFAULT_ORDER.should eq(
      "bit_score DESC"
    )
  end

end

