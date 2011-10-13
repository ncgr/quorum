module Quorum
  class BlastReport < ActiveRecord::Base
    belongs_to :blast

    paginates_per 20
    SORTABLE_COLUMNS = ["query", "bit_score", "hit_len"]
    DEFAULT_ORDER    = "bit_score DESC"
  end
end
