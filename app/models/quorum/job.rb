module Quorum
  class Job < ActiveRecord::Base
  
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

    attr_accessible :sequence, :na_sequence, :aa_sequence

    accepts_nested_attributes_for :blastn_job, :blastx_job, :tblastn_job,
      :blastp_job, :hmmer_job

    validates_associated :blastn_job, :blastx_job, :tblastn_job, :blastp_job,
      :hmmer_job

    validates_length_of :sequence, 
      :minimum     => 20,
      :message     => " - Please upload sequences in FASTA format.",
      :allow_blank => false  

    validate :filter_input_sequences

    private

    #
    # Filter input sequences by type (AA or NA).
    #
    def filter_input_sequences
      hash = Digest::MD5.hexdigest(self.sequence).to_s + "-" + Time.now.to_i.to_s
      tmp  = File.join(::Rails.root.to_s, 'tmp')

      begin
        write_input_sequence_to_file(tmp, hash, self.sequence)
      rescue Exception => e
        errors.add(:sequence, e.message)
        return
      else
        fasta = File.read(File.join(tmp, hash + ".fa"))
      ensure
        File.delete(File.join(tmp, hash + ".fa"))
        File.delete(File.join(tmp, hash + ".seq"))
      end

      self.na_sequence = ""
      self.aa_sequence = ""

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
    # Write input sequence to file. Pass the raw input data through seqret
    # to ensure FASTA format.
    #
    def write_input_sequence_to_file(tmp_dir, hash, sequence)
      seq = File.join(tmp_dir, hash + ".seq") 
      File.open(seq, "w") do |f|
        f << sequence
      end

      fasta = File.join(tmp_dir, hash + ".fa")

      # Force FASTA format.
      cmd = "seqret -filter -sformat pearson -osformat fasta < #{seq} " <<
      "> #{fasta} 2> /dev/null"
      system(cmd)
      if $?.exitstatus > 0
        raise " - Please enter your sequence(s) in Plain Text as " <<
          "FASTA."
      end
    end

    #
    # Discover input sequence type (nucleic acid NA or amino acid AA).
    #
    # Subtracting all AA single letter chars from NA single letter chars
    # (including ALL ambiguity codes for each!) leaves us with
    # EQILFP. If a sequence contains EQILFP, it's safe to call it an AA. 
    #
    # See single letter char tables for more information:
    # http://en.wikipedia.org/wiki/Proteinogenic_amino_acid
    # http://www.chick.manchester.ac.uk/SiteSeer/IUPAC_codes.html
    #
    # If a sequence doesn't contain EQILFP, it could be either an AA 
    # or NA. To distinguish the two, count the number of As Ts Gs Cs
    # and Ns, divide by the the length of the sequence and * 100.
    #
    # If the percentage of A, T, U, G, C or N is >= 15.0, call it a NA.
    # 15% was choosen based on the data in the table 
    # "Relative proportions (%) of bases in DNA" 
    # (http://en.wikipedia.org/wiki/Chargaff's_rules) and the
    # precentage of AAs found in peptides
    # (http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2590925/).
    #
    def discover_input_sequence_type(sequence)
      # Index of the first newline char.
      start = sequence.index(/\n/)
      # Remove the sequence FASTA header.
      seq   = sequence.slice(start..-1).gsub!(/\n/, '')

      if seq =~ /[EQILFP]+/
        type = "amino_acid"
      else
        # Length of the sequence minus the FASTA header.
        len = seq.length.to_f

        na_percent = 15.0

        a = (seq.count("A").to_f / len) * 100
        t = (seq.count("T").to_f / len) * 100
        u = (seq.count("U").to_f / len) * 100

        g = (seq.count("G").to_f / len) * 100
        c = (seq.count("C").to_f / len) * 100

        n = (seq.count("N").to_f / len) * 100

        if (a >= na_percent) || (t >= na_percent) || (u >= na_percent) || 
          (g >= na_percent) || (c >= na_percent) || (n >= na_percent)
          type = "nucleic_acid"
        else
          type = "amino_acid"
        end
      end
      type
    end

  end
end
