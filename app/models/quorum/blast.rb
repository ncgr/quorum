module Quorum
  class Blast < ActiveRecord::Base

    attr_accessible :sequence_type, :sequence

    validates_format_of :sequence_type, 
      :with => /[a-z_]+/,
      :message => " - Please select a valid sequence type.",
      :allow_blank => false
    validates_length_of :sequence, 
      :minimum => 20,
      :message => " - Please insert valid sequences.",
      :allow_blank => false

    validate :validate_sequence_size

    #
    # Validates size of the user's sequence(s) against max. 
    # Max defaults to 50KB.
    #
    def validate_sequence_size
      max  = 50000
      size = self.sequence.bytesize

      if size > max
        errors.add(:sequence_size_too_large, 
                   "- Your sequence(s) exceed the size limit of 50KB.")
      end
    end

  end
end
