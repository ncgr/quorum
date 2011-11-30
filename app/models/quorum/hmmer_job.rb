module Quorum
  class HmmerJob < ActiveRecord::Base

    before_save :set_optional_params

    belongs_to :job
    has_many :hmmer_job_reports, :dependent => :destroy

    attr_accessible :expectation, :min_score, :queue

    validates_format_of :expectation,
      :with        => /^[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :min_score,
      :only_integer => true,
      :allow_blank  => true

    private

    def set_optional_params
      self.expectation = "5e-20" if self.expectation.blank?
      self.min_score   ||= 0
    end

  end
end
