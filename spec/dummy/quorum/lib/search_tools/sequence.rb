module Quorum
  module Utils
    module Sequence

      #
      # Create a unique hash.
      #
      def create_unique_hash(string)
        Digest::MD5.hexdigest(string).to_s + "-" + Time.now.to_i.to_s
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
          raise RuntimeError "Input sequence not in FASTA format."
        end
        fasta
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
      def discover_input_sequence_type(fasta)
        file  = File.open(fasta)

        # If we make this far, we know the sequences are in FASTA format.
        seqs  = file.read.split('>')
        seqs.delete_if { |l| l.empty? }

        stats    = [] # Holds the sequence call. 1 = AA, 0 = NA.
        num_seqs = seqs.length.to_f

        seqs.each do |s|
          # Index of the first newline char.
          start = s.index(/\n/)
          # Remove the sequence FASTA header.
          seq   = s.slice(start..-1).gsub!(/\n/, '')

          if seq =~ /[EQILFP]+/
            stats << 1
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
              stats << 0
            else
              stats << 1
            end
          end
        end

        # Sum the values in the array.
        sum = stats.inject(0) { |s, v| s + v }

        # Divide the sum by the number of input sequences. If the value
        # is > 0.5, call it an AA. If the value is < 0.5, call it a NA.
        begin
          if ((sum.to_f / num_seqs)  > 0.5)
            type = "amino_acid"
          else
            type = "nucleic_acid"
          end
          return type
        rescue ZeroDivisionError => e
          raise e
        end
      end

    end
  end
end
