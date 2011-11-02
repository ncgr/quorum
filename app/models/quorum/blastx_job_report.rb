module Quorum
  class BlastxJobReport < ActiveRecord::Base
    belongs_to :blastx_job

    paginates_per 20
    SORTABLE_COLUMNS = ["query", "bit_score", "hit_len"]
    DEFAULT_ORDER    = "bit_score DESC"
  end
end
