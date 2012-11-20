module Quorum
  module JobSerializer

    #
    # Convert jobs to json. Uses Rails default.
    #
    def self.as_json(job)
      if job.respond_to?(:errors) && job.errors.present?
        { errors: job.errors.full_messages }
      else
        job.as_json(root: false)
      end
    end

    #
    # Convert jobs to tab delimited output.
    #
    def self.as_txt(job)
      txt = ""
      values = [
        "query",
        "hit_display_id",
        "pct_identity",
        "align_len",
        "mismatch",
        "gaps",
        "query_from",
        "query_to",
        "hit_from",
        "hit_to",
        "evalue",
        "bit_score"
      ]

      job.each do |j|
        txt << j.attributes.values_at(*values).join("\t") << "\n"
      end
      txt
    end

    #
    # Convert jobs to GFF.
    #
    def self.as_gff(job)
      pragma = "##gff-version 3\n"
      source = "."
      type   = "match"
      phase  = "."
      txt    = ""
      job.each do |j|
        if j.results
          # Add sequence-region.
          unless pragma.include?(j.hit_display_id)
            pragma << "##sequence-region #{j.hit_display_id} 1 #{j.hit_len}\n"
          end

          start, stop = j.hit_from, j.hit_to

          # Set the strand based on the original start, stop.
          start > stop ? strand = "-" : strand = "+"
          # Format the start, stop for GFF.
          start, stop = format_hit_start_stop(start, stop)

          values = [
            j.hit_display_id,
            source,
            type,
            start,
            stop,
            j.evalue,
            strand,
            phase
          ]

          txt << values.join("\t") << "\tTarget=#{j.query} " <<
            "#{j.query_from} #{j.query_to};Name=#{j.query};" <<
            "identity=#{j.pct_identity};rawscore=#{j.score};" <<
            "significance=#{j.evalue}\n"
        end
      end
      txt.insert(0, pragma)
    end

    #
    # Start must be <= to stop.
    #
    def self.format_hit_start_stop(start, stop)
      tmp_start, tmp_stop = start, stop
      if start > stop
        tmp_start, tmp_stop = stop, start
      end
      return tmp_start, tmp_stop
    end

  end
end
