module Quorum
  class BlastpJobReport < ActiveRecord::Base
    belongs_to :blastp_job

    paginates_per 20
    SORTABLE_COLUMNS = ["query", "bit_score", "hit_len"]
    DEFAULT_ORDER    = "bit_score DESC"
  end
end
