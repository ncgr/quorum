module Quorum
  module Sequence

    #
    # Create a unique hash plus timestamp.
    #
    def create_hash(sequence)
      Digest::MD5.hexdigest(sequence).to_s + "-" + Time.now.to_f.to_s
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
      seq = sequence.slice(start..-1).gsub!(/\n/, '')

      if seq =~ /[EQILFPeqilfp]+/
        type = "amino_acid"
      else
        # Length of the sequence minus the FASTA header.
        len = seq.length.to_f

        na_percent = 15.0
        counts     = []

        counts << (seq.count("Aa").to_f / len) * 100
        counts << (seq.count("Tt").to_f / len) * 100
        counts << (seq.count("Uu").to_f / len) * 100

        counts << (seq.count("Gg").to_f / len) * 100
        counts << (seq.count("Cc").to_f / len) * 100

        counts << (seq.count("Nn").to_f / len) * 100

        counts.reject! { |c| c < na_percent }
        if (!counts.empty?)
          type = "nucleic_acid"
        else
          type = "amino_acid"
        end
      end
      type
    end


    #
    # Send sequence data to the browser.
    #
    module SendSequence

      def sequence(data)
        @data = data
        if @data.respond_to?(:succeeded?) && @data.succeeded?
          if self.has_error?
            return self.render_error
          else
            return send_data @data.result,
              :filename     => @data.meta_id,
              :type         => "text/plain",
              :disposition  => "attachment"
          end
        end
        self.render_empty
      end

      def has_error?
        @data.result.downcase.include?("error")
      end

      def render_error
        render :text => @data.result
      end

      def render_empty
        render :text => ""
      end

    end

  end
end
