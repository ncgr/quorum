module Quorum
  class Blast < ActiveRecord::Base

    attr_accessible :sequence_type, :sequence, :expectation, :max_score,
      :min_bit_score, :gapped_alignments, :gap_opening_penalty,
      :gap_extension_penalty

    validates_format_of :sequence_type, 
      :with        => /[a-z_]+/,
      :message     => " - Please select a valid sequence type.",
      :allow_blank => false
    validates_length_of :sequence, 
      :minimum     => 20,
      :message     => " - Please upload sequences in FASTA format.",
      :allow_blank => false  
    validates_format_of :expectation,
      :with        => /^[+-]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/,
      :message     => " - Valid formats (12, 32.05, 43e-123)",
      :allow_blank => true
    validates_numericality_of :max_score,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :min_bit_score,
      :allow_blank => true
    validates_numericality_of :gap_opening_penalty,
      :allow_blank => true
    validates_numericality_of :gap_extension_penalty,
      :allow_blank => true 

  end
end
