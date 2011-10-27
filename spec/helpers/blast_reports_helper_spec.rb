require "spec_helper"

describe Quorum::BlastReportsHelper do
  describe "#format_sequence_report" do

    it "formats Blast report sequence data. (qseq, hseq and midline)" do
      qseq    = "GSISIRTETGIIKSSKVAETMEKIDRGLFVPNGVQPYIDSPMSIGYNATISAPHMHATCLQLLENYLQ"
      midline = "G +    + G+IKS KVAE ME IDRGLFVPNG QPY+DSPM IGYNATISAPHMHATCLQLLE  LQ"
      hseq    = "GMVENLQQYGVIKSRKVAEIMETIDRGLFVPNGAQPYVDSPMLIGYNATISAPHMHATCLQLLEENLQ"
      helper.format_sequence_report(qseq, midline, hseq).should eq(
"<pre>
GSISIRTETGIIKSSKVAETMEKIDRGLFVPNGVQPYIDSPMSIGYNATISAPHMHATCL
G +    + G+IKS KVAE ME IDRGLFVPNG QPY+DSPM IGYNATISAPHMHATCL
GMVENLQQYGVIKSRKVAEIMETIDRGLFVPNGAQPYVDSPMLIGYNATISAPHMHATCL

QLLENYLQ
QLLE  LQ
QLLEENLQ

</pre>"
      )
    end

  end
end