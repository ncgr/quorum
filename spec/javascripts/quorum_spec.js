//
// QUORUM Specs
//

describe("QUORUM", function() {

  //
  // Spec covers QUORUM.algorithms.
  //
  // QUORUM.algorithms should be an array of strings.
  //
  it("contains an array of strings", function() {
    expect(QUORUM.algorithms.join('')).toMatch(/[a-zA-Z]/g);
  });

  //
  // Spec covers QUORUM.pollResults.
  //
  // QUORUM.pollResults calls itself via setTimeout() if the returned JSON
  // dataset is empty.
  //
  // If callback is defined, call callback function. Otherwise call default
  // anonymous function buildTemplate().
  //
  it("fetches JSON and calls user defined callback function", function() {
    spyOn($, 'getJSON');
    spyOn(window, 'setTimeout');
    var id = 1,
        callback = jasmine.createSpy(),
        data = 'foo';

    QUORUM.pollResults(id, callback, null, 5000, ['a']);

    // setTimeout()
    $.getJSON.mostRecentCall.args[1]('');
    expect(window.setTimeout).toHaveBeenCalled();

    // callback()
    $.getJSON.mostRecentCall.args[1](data);
    expect(callback).toHaveBeenCalledWith(id, data, 'a');
  });

  //
  // Spec covers QUORUM.viewDetailedReport.
  //
  // Open detailed report dialog modal box and load template.
  //
  it("renders modal box containing detailed report", function() {
    loadFixtures('quorum_tabs.html');

    spyOn($, 'getJSON');
    spyOn(QUORUM, 'autoScroll');
    var id = 1,
        focus_id = 1,
        query = 'foo',
        algo = 'a',
        data = 'bar';

    QUORUM.viewDetailedReport(id, focus_id, query, algo);

    expect($("#detailed_report_dialog")).toBeVisible();

    // Fetch JSON to build the template and scroll to focus_id.
    $.getJSON.mostRecentCall.args[1](data);
    expect(QUORUM.autoScroll).toHaveBeenCalledWith(focus_id, false);

    // Close the dialog box.
    $("#detailed_report_dialog").dialog('close');
  });

  //
  // Spec covers QUORUM.formatSequenceReport & QUORUM.addBaseTitleIndex.
  //
  // Blastn should increment qseq's title by 1 and hseq's title by 1.
  //
  it("formats blastn sequence report for Blast detailed report", function() {
    var report = QUORUM.formatSequenceReport(
      "ACGT", "|| |", "ACCT", 6, 9, 2, 8, "blastn"
    );
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small sequence'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=7>C</a><a rel='quorum-tipsy' title=8>G</a><a rel='quorum-tipsy' title=9>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
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
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small sequence'><pre>\nqseq <a rel='quorum-tipsy' title=6>A</a><a rel='quorum-tipsy' title=9>C</a><a rel='quorum-tipsy' title=12>G</a><a rel='quorum-tipsy' title=15>T</a>\n     || |\nhseq <a rel='quorum-tipsy' title=2>A</a><a rel='quorum-tipsy' title=3>C</a><a rel='quorum-tipsy' title=4>C</a><a rel='quorum-tipsy' title=5>T</a>\n\n</pre></span>");
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
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small sequence'><pre>\nqseq <a rel='quorum-tipsy' title=10>E</a><a rel='quorum-tipsy' title=11>L</a><a rel='quorum-tipsy' title=12>V</a><a rel='quorum-tipsy' title=13>I</a><a rel='quorum-tipsy' title=14>S</a>\n     ELVIS\nhseq <a rel='quorum-tipsy' title=121>E</a><a rel='quorum-tipsy' title=124>L</a><a rel='quorum-tipsy' title=127>V</a><a rel='quorum-tipsy' title=130>I</a><a rel='quorum-tipsy' title=133>S</a>\n\n</pre></span>");
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
    expect(report).toEqual("<p class='small'>Alignment (Mouse over for positions):</p><span class='small sequence'><pre>\nqseq <a rel='quorum-tipsy' title=10>E</a><a rel='quorum-tipsy' title=11>L</a><a rel='quorum-tipsy' title=12>V</a><a rel='quorum-tipsy' title=13>I</a><a rel='quorum-tipsy' title=14>S</a>\n     ELVIS\nhseq <a rel='quorum-tipsy' title=121>E</a><a rel='quorum-tipsy' title=122>L</a><a rel='quorum-tipsy' title=123>V</a><a rel='quorum-tipsy' title=124>I</a><a rel='quorum-tipsy' title=125>S</a>\n\n</pre></span>");
  });

  //
  // jQuery tipsy plugin should display anchor's title attribute on mouseover
  // and hide on mouseout.
  //
  it("should display title via jquery.tipsy on mouse over and hide on mouse out", function() {
    loadFixtures('formatted_sequence.html');
    $('.sequence').mouseenter(function() {
      $(this).find('a[rel=quorum-tipsy]').tipsy({ gravity: 's' });
    });

    $('a[rel=quorum-tipsy]').trigger('mouseover');
    expect($('.tipsy')).toBeVisible();

    $('a[rel=quorum-tipsy]').trigger('mouseout');
    expect($('.tipsy')).not.toBeVisible();
  });

  //
  // Spec covers QUORUM.formatStrand.
  //
  // If number is > 0 print forward.
  // If number is < 0 print reverse.
  //
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
  // Spec covers QUORUM.formatEvalue
  //
  // Format Blast Evalues for HTML.
  //
  it("returns empty string if evalue is not set", function() {
    expect(QUORUM.formatEvalue("")).toEqual("");
    expect(QUORUM.formatEvalue(null)).toEqual("");
    expect(QUORUM.formatEvalue(undefined)).toEqual("");
  });

  it("formats blast evalue", function() {
    expect(QUORUM.formatEvalue("0")).toEqual("0.0");
    expect(QUORUM.formatEvalue("0.0")).toEqual("0.0");
    expect(QUORUM.formatEvalue("1.23966346466766e-65")).toEqual("1.2 x 10<sup>-65</sup>");
    expect(QUORUM.formatEvalue("1.2966346466766e-165")).toEqual("1.3 x 10<sup>-165</sup>");
    expect(QUORUM.formatEvalue("1.23456789")).toEqual("1.2");
  });

  //
  // Spec covers QUORUM.displayHspLinks.
  //
  // Only print links to HSPs whers data id != focus.
  //
  it("prints HSP links", function() {
    var focus = 1,
        group = "1,2",
        data = [
          {"id":1,"hsp_group":"1,2","hsp_num":1},
          {"id":2,"hsp_group":"1,2","hsp_num":2}
        ];

    var hsps = QUORUM.displayHspLinks(focus, group, data);
    expect(hsps).toEqual("Related <a onclick=\"(QUORUM.openWindow('http://www.ncbi.nlm.nih.gov/books/NBK62051/def-item/blast_glossary.HSP','HSP', 800, 300))\">HSPs</a>: 1 <a onclick='(QUORUM.autoScroll(2, true))'>2</a> ");
  });

  //
  // QUORUM.displayHspLinks should return an empty string if group is not set.
  //
  it("prints HSP links", function() {
    var focus = 1,
        group = null,
        data = [
          {"id":1,"hsp_group":"1,2","hsp_num":1},
          {"id":2,"hsp_group":"1,2","hsp_num":2}
        ];

    var hsps = QUORUM.displayHspLinks(focus, group, data);
    expect(hsps).toEqual("");
  });

  //
  // Spec covers QUORUM.downloadSequence.
  //
  // Download a Blast hit sequence file.
  //
  it("sends request to server to extract Blast hit sequence", function() {
    loadFixtures("quorum_tabs.html");

    spyOn($, 'getJSON');
    spyOn(QUORUM, 'getSequenceFile');
    var id = 1,
        algo_id = 1,
        algo = 'a',
        el = $("#download_sequence"),
        data = [{meta_id:"foo"}];

    QUORUM.downloadSequence(id, algo_id, algo, el);

    expect(el.html()).toEqual('Fetching sequence...');

    $.getJSON.mostRecentCall.args[1](data);
    expect(QUORUM.getSequenceFile).toHaveBeenCalledWith(id, data[0].meta_id, el);
  });

  //
  // Spec covers QUORUM.getSequenceFile.
  //
  // Poll application for Blast hit sequence file and force browser to
  // download via iframe.
  //
  it("polls server to extract Blast hit sequence, once found, force browser to download via iframe", function() {
    loadFixtures("quorum_tabs.html");

    spyOn($, 'get');
    spyOn(window, 'setTimeout');
    var id = 1,
        meta_id = 'foo',
        el = $("#download_sequence"),
        data = 'bar',
        error = 'error';

    QUORUM.getSequenceFile(id, meta_id, el);

    // setTimeout()
    $.get.mostRecentCall.args[1]('');
    expect(window.setTimeout).toHaveBeenCalled();

    // Print error message
    $.get.mostRecentCall.args[1](error);
    expect(el.html()).toEqual(error);

    // Force browser to download file.
    $.get.mostRecentCall.args[1](data);
    expect(el.html()).toEqual('Sequence Downloaded Successfully');
    expect($('iframe.quorum_sequence_download')).toBeDefined();
    $('.quorum_sequence_download').remove();
  });

  //
  // Spec covers QUORUM.openWindow.
  //
  // Open a URL in a new window.
  //
  it("opens url in a new window", function() {
    spyOn(window, 'open');
    var url = "http://google.com",
        name = "Google",
        width = 300,
        height = 300;

    QUORUM.openWindow(url, name, width, height);
    expect(window.open).toHaveBeenCalledWith(url, name, "width=" + width + ",height=" + height + ",scrollbars=yes");
  });

});
