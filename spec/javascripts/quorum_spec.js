//
// Test the methods not covered in RSpec request specs.
//

describe("QUORUM", function() {

  //
  // Spec covers QUORUM.formatSequenceReport & QUORUM.addBaseTitleIndex.
  //
  // Blastn should increment qseq's title by 1 and hseq's title by 1.
  //
  it("formats blastn sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ACGT", "|| |", "ACCT", 6, 9, 2, 8, "blastn"
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=7>C</a><a rel='quorum-tipsy' title=8>G</a><a rel='quorum-tipsy' title=9>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
  });

  //
  // Spec covers QUORUM.formatSequenceReport & QUORUM.addBaseTitleIndex.
  //
  // Blastx should increment qseq's title by 3 and hseq's title by 1.
  //
  it("formats blastx sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ACGT", "|| |", "ACCT", 6, 9, 2, 8, "blastx"
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=9>C</a><a rel='quorum-tipsy' title=12>G</a><a rel='quorum-tipsy' title=15>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
  });

  //
  // Spec covers QUORUM.formatSequenceReport & QUORUM.addBaseTitleIndex.
  //
  // Tblastn should increment qseq's title by 1 and hseq's title by 3.
  //
  it("formats tblastn sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ELVIS", "ELVIS", "ELVIS", 10, 14, 121, 136, "tblastn"
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=10>E</a><a rel='quorum-tipsy' title=11>L</a><a rel='quorum-tipsy' title=12>V</a><a rel='quorum-tipsy' title=13>I</a><a rel='quorum-tipsy' title=14>S</a>\n     ELVIS\nhseq <a rel='quorum-tipsy' title=121>E</a><a rel='quorum-tipsy' title=124>L</a><a rel='quorum-tipsy' title=127>V</a><a rel='quorum-tipsy' title=130>I</a><a rel='quorum-tipsy' title=133>S</a>\n\n</pre></span>");
  });

  //
  // Spec covers QUORUM.formatSequenceReport & QUORUM.addBaseTitleIndex.
  //
  // Blastp should increment qseq's title by 1 and hseq's title by 1.
  //
  it("formats blastx sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ELVIS", "ELVIS", "ELVIS", 10, 14, 121, 125, "blastp"
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small'><pre>\nqseq <a rel='quorum-tipsy' title=10>E</a><a rel='quorum-tipsy' title=11>L</a><a rel='quorum-tipsy' title=12>V</a><a rel='quorum-tipsy' title=13>I</a><a rel='quorum-tipsy' title=14>S</a>\n     ELVIS\nhseq <a rel='quorum-tipsy' title=121>E</a><a rel='quorum-tipsy' title=122>L</a><a rel='quorum-tipsy' title=123>V</a><a rel='quorum-tipsy' title=124>I</a><a rel='quorum-tipsy' title=125>S</a>\n\n</pre></span>");
  });

  it("should display title via jquery.tipsy on mouse over hide on mouse out", function() {
    loadFixtures('formatted_sequence.html');
    $('a[rel=quorum-tipsy]').tipsy({ gravity: 's' });

    $('a[rel=quorum-tipsy]').trigger('mouseover');
    expect($('.tipsy')).toBeVisible();

    $('a[rel=quorum-tipsy]').trigger('mouseout');
    expect($('.tipsy')).not.toBeVisible();
  });

  it("prints hit strand as forward / forward for + / + intergers", function() {
    expect(QUORUM.formatStrand(1, 1)).toEqual("forward / forward");
  });

  it("prints hit strand as forward / reverse for + / - integers", function() {
    expect(QUORUM.formatStrand(1, -1)).toEqual("forward / reverse");
  });

  it("prints hit strand as reverse / forward for - / + integers", function() {
    expect(QUORUM.formatStrand(-1, 1)).toEqual("reverse / forward");
  });

  it("prints hit strand as reverse / reverse for - / - integers", function() {
    expect(QUORUM.formatStrand(-1, -1)).toEqual("reverse / reverse");
  });

  //
  // Only print links to HSPs whers data id != focus.
  //
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
