module Quorum
  class TblastxJob < ActiveRecord::Base

    before_validation :check_blast_dbs, :if => :queue

    before_save :set_optional_params, :set_blast_dbs

    belongs_to :job
    has_many :tblastx_job_reports,
      :dependent   => :destroy,
      :foreign_key => :tblastx_job_id,
      :primary_key => :job_id

    attr_accessible :expectation, :max_target_seqs, :min_bit_score,
      :filter, :queue, :blast_dbs

    validates_format_of :expectation,
      :with        => /^[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :max_target_seqs,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :min_bit_score,
      :only_integer => true,
      :allow_blank  => true
    validates_presence_of :blast_dbs, :if => :queue

    private

    def check_blast_dbs
      if self.blast_dbs.present?
        self.blast_dbs = self.blast_dbs.delete_if { |b| b.empty? }
      end
    end

    def set_blast_dbs
      if self.blast_dbs.present?
        self.blast_dbs = self.blast_dbs.join(';')
      end
    end

    def set_optional_params
      self.expectation = "5e-20" if self.expectation.blank?
      self.max_target_seqs ||= 25
      self.min_bit_score ||= 0
    end

  end
end
