module Quorum
  class Job < ActiveRecord::Base
  
    include Quorum::Sequence

    has_one :blastn_job, :dependent => :destroy
    has_many :blastn_job_reports, :through => :blastn_job

    has_one :blastx_job, :dependent => :destroy
    has_many :blastx_job_reports, :through => :blastx_job

    has_one :tblastn_job, :dependent => :destroy
    has_many :tblastn_job_reports, :through => :tblastn_job

    has_one :blastp_job, :dependent => :destroy
    has_many :blastp_job_reports, :through => :blastp_job

    has_one :hmmer_job, :dependent => :destroy
    has_many :hmmer_job_reports, :through => :hmmer_job

    accepts_nested_attributes_for :blastn_job, :blastx_job, :tblastn_job,
      :blastp_job, :hmmer_job,
      :reject_if => proc { |attributes| attributes['queue'] == false }

    attr_accessible :sequence, :na_sequence, :aa_sequence, 
      :blastn_job_attributes, :blastx_job_attributes, :tblastn_job_attributes,
      :blastp_job_attributes, :hmmer_job_attributes

    validates_associated :blastn_job, :blastx_job, :tblastn_job, :blastp_job,
      :hmmer_job

    validate :filter_input_sequences, :algorithm_selected

    private

    #
    # Filter input sequences by type (AA or NA) and place each in it's
    # appropriate attribute.
    #
    def filter_input_sequences
      # Ensure the sequences are in plain text.
      begin
        ActiveSupport::Multibyte::Unicode.u_unpack(self.sequence)
      rescue ActiveSupport::Multibyte::EncodingError => e
        logger.error e.message
        errors.add(
          :sequence, 
          "Please enter your sequence(s) in Plain Text as FASTA."
        )
        self.sequence = ""
        return
      end

      hash = create_hash(self.sequence)
      tmp  = File.join(::Rails.root.to_s, 'tmp')

      # Ensure the sequences are FASTA via #write_input_sequence_to_file.
      begin
        write_input_sequence_to_file(tmp, hash, self.sequence)
      rescue Exception => e
        errors.add(:sequence, e.message)
        return
      else
        fasta = File.read(File.join(tmp, hash + ".fa"))
      ensure
        #File.delete(File.join(tmp, hash + ".fa"))
        #File.delete(File.join(tmp, hash + ".seq"))
      end

      self.na_sequence = ""
      self.aa_sequence = ""

      # Split the sequences on >, check the type (AA or NA) and separate. 
      seqs = fasta.split('>')
      seqs.delete_if { |s| s.empty? }
      seqs.each do |s|
        type = discover_input_sequence_type(s)
        if type == "nucleic_acid"
          self.na_sequence << ">" << s
        end
        if type == "amino_acid"
          self.aa_sequence << ">" << s
        end 
      end   

      self.na_sequence = nil if self.na_sequence.empty?
      self.aa_sequence = nil if self.aa_sequence.empty?

      self.sequence_hash = hash
    end

    #
    # Make sure an algorithm is selected.
    #
    def algorithm_selected
      in_queue = false
      if self.blastn_job.queue || self.blastx_job.queue ||
        self.tblastn_job.queue || self.blastp_job.queue ||
        self.hmmer_job.queue
        in_queue = true
      end
      unless in_queue
        errors.add(
          :algorithm, 
          " - Please select at least one algorithm to continue."
        )
      end
    end

  end
end
