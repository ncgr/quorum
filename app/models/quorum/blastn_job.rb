module Quorum
  class BlastnJob < ActiveRecord::Base

    belongs_to :job
    has_many :blastn_job_reports, :dependent => :destroy

    attr_accessible :expectation, :max_score, :min_bit_score,
      :filter,  :gapped_alignments, :gap_opening_penalty,
      :gap_extension_penalty, :gap_opening_extension

    validates_format_of :expectation,
      :with        => /^[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :max_score,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :min_bit_score,
      :only_integer => true,
      :allow_blank => true
    validates_numericality_of :gap_opening_penalty,
      :only_integer => true,
      :allow_blank => true
    validates_numericality_of :gap_extension_penalty,
      :only_integer => true,
      :allow_blank => true
    validate :gap_opening_extension_exists

    #
    # Gapped alignment helper.
    #
    def gapped_alignment?
      self.gapped_alignments
    end

    #
    # Valid gap opening and extension values.
    #
    def gap_opening_extension_values
      [
        ['--Select--', ''],
        ['32767, 32767', '32767,32767'],
        ['11, 2', '11,2'],
        ['10, 2', '10,2'],
        ['9, 2', '9,2'],
        ['8, 2', '8,2'],
        ['7, 2', '7,2'],
        ['6, 2', '6,2'],
        ['13, 1', '13,1'],
        ['12, 1', '12,1'],
        ['11, 1', '11,1'],
        ['10, 1', '10,1'],
        ['9, 1', '9,1']
      ]
    end

    #
    # Virtual attribute getter.
    #
    def gap_opening_extension
      [gap_opening_penalty, gap_extension_penalty].join(',')
    end

    #
    # Virtual attribute setter.
    #
    def gap_opening_extension=(value)
      v = value.split(',')
      self.gap_opening_penalty   = v.first
      self.gap_extension_penalty = v.last
    end

    private

    #
    # Add error if gapped_alignment? without gap_opening_extension.
    #
    def gap_opening_extension_exists
      if gap_opening_extension.split(',').blank? && gapped_alignment?
        errors.add(
          :gap_opening_extension,
          " - Please select a value."
        )
      end
    end

  end
end
