module Quorum
  class BlastnJobReport < ActiveRecord::Base
    belongs_to :blastn_job

    paginates_per 20
    SORTABLE_COLUMNS = ["query", "bit_score", "hit_len"]
    DEFAULT_ORDER    = "bit_score DESC"
  end
end
