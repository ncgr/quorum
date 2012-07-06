module Quorum
  module DataExport

    #
    # Convert search results to tab delimited output.
    #
    def to_txt
      txt = ""
      values = [
        "query",
        "hit_display_id",
        "identity",
        "align_len",
        "query_from",
        "query_to",
        "hit_from",
        "hit_to",
        "evalue",
        "bit_score"
      ]

      all.each do |d|
        txt << d.attributes.values_at(*values).join("\t") << "\n"
      end

      txt
    end

    #
    # Convert search results to GFF.
    #
    def to_gff
      txt    = "##gff-version 3\n"
      source = "."
      type   = "match"
      phase  = "."
      all.each do |d|
        if d.results
          start, stop = d.hit_from, d.hit_to

          # Set the strand based on the original start, stop.
          start > stop ? strand = "-" : strand = "+"
          # Format the start, stop for GFF.
          start, stop = format_hit_start_stop(start, stop)

          values = [
            d.hit_display_id,
            source,
            type,
            start,
            stop,
            d.evalue,
            strand,
            phase
          ]

          txt << values.join("\t") << "\tTarget=#{d.hit_display_id} " <<
            "#{d.query_from} #{d.query_to};Name=#{d.hit_display_id}\n"
        end
      end
      txt
    end

    #
    # Start must be <= to stop.
    #
    def format_hit_start_stop(start, stop)
      tmp_start, tmp_stop = start, stop

      if start > stop
        tmp_start, tmp_stop = stop, start
      end
      return tmp_start, tmp_stop
    end

  end
end
