//
// Test the methods not covered in the RSpec request specs.
//

describe("QUORUM", function() {

  it("formats blastn sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ACGT", "|| |", "ACCT", 6, 9, 2, 8, "blastn"  
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=7>C</a><a rel='quorum-tipsy' title=8>G</a><a rel='quorum-tipsy' title=9>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
  });

  it("formats blastx sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ACGT", "|| |", "ACCT", 6, 9, 2, 8, "blastx"  
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=9>C</a><a rel='quorum-tipsy' title=12>G</a><a rel='quorum-tipsy' title=15>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
  });

  it("prints hit strand as forward / forward for + intergers", function() {
    expect(QUORUM.formatStrand(1, 1)).toEqual("forward / forward");
  }); 

  it("prints hit strand as forward / reverse for + / - integer", function() {
    expect(QUORUM.formatStrand(1, -1)).toEqual("forward / reverse");
  }); 

  it("prints hit strand as reverse / forward for - / + integer", function() {
    expect(QUORUM.formatStrand(-1, 1)).toEqual("reverse / forward");
  }); 

  it("prints hit strand as reverse / reverse for - / - integer", function() {
    expect(QUORUM.formatStrand(-1, -1)).toEqual("reverse / reverse");
  }); 

  it("prints HSP links", function() {
    var focus = 1;
    var group = "1,2";
    var data  = [
      {"id":1,"hsp_group":"1,2","hsp_num":1},
      {"id":2,"hsp_group":"1,2","hsp_num":2}
    ];
    var hsps  = QUORUM.displayHspLinks(focus, group, data);
    expect(hsps).toEqual("Related <a onclick=\"(QUORUM.openWindow('http://www.ncbi.nlm.nih.gov/books/NBK62051/def-item/blast_glossary.HSP','HSP', 800, 300))\">HSPs</a>: 1 <a onclick='(QUORUM.autoScroll(2, true))'>2</a> ");
  });

  it("opens url in a new window", function() {
    spyOn(window, 'open');
    var url    = "http://google.com";
    var name   = "Google";
    var width  = 300;
    var height = 300;
    QUORUM.openWindow(url, name, width, height);
    expect(window.open).toHaveBeenCalledWith(url, name, "width=" + width + ",height=" + height + ",scrollbars=yes");
  });

});
