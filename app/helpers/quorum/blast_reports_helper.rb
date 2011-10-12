module Quorum
  module BlastReportsHelper

    #
    # Format Blast report sequence data.
    #
    def format_sequence_report(qseq, midline, hseq)
      max  = qseq.length
      s    = 0
      e    = 60
      str  = "\n"
      while true do
        if e >= max
          str << qseq[s...max] << "\n"
          str << midline[s...max] << "\n"
          str << hseq[s...max] << "\n\n"
          break
        end
        str << qseq[s...e] << "\n"
        str << midline[s...e] << "\n"
        str << hseq[s...e] << "\n\n"
        s += 60
        e += 60
      end
      content_tag(:pre, str)
    end

  end
end
