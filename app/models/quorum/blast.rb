module Quorum
  class Blast < ActiveRecord::Base

    attr_accessible :sequence_type, :sequence 

    validates_format_of :sequence_type, 
      :with => /[a-z_]+/,
      :message => " - Please select a valid sequence type.",
      :allow_blank => false
    validates_length_of :sequence, 
      :minimum => 20,
      :message => " - Please upload sequences in FASTA format.",
      :allow_blank => false  

  end
end
