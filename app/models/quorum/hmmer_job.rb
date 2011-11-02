module Quorum
  class HmmerJob < ActiveRecord::Base

    belongs_to :job
    has_many :hmmer_job_reports, :dependent => :destroy

    attr_accessible :expectation, :min_score

    validates_format_of :expectation,
      :with        => /^[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :min_score,
      :only_integer => true,
      :allow_blank => true

  end
end
