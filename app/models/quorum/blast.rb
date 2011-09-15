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

    #
    # Create a unique hash based on self.sequence.
    #
    def create_unique_hash
      return nil if self.sequence.blank?
      Digest::MD5.hexdigest(self.sequence).to_s + "-" + Time.now.to_f.to_s
    end
  end
end
