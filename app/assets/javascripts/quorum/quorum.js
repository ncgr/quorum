//
// QUORUM
//---------------------------------------------------------------------------// 

var QUORUM = {

  //
  // Supported algorithms.
  //
  algorithms: ["blastn", "blastx", "tblastn", "blastp"],
  
  // 
  // Poll quorum search results asynchronously and insert them into
  // the DOM via #blast_template.
  //
  pollResults: function(id, interval, algos) {
  
    // Set the default poll interval to 5 seconds.
    interval = interval || 5000;
  
    // Algorithms
    algos = algos || QUORUM.algorithms;
  
    _.each(algos, function(a) {
      $.getJSON(
        '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + a,
        function(data) {
          if (data.length === 0) {
            setTimeout(function() { 
              QUORUM.pollResults(id, interval, [a]); 
            }, interval);
          } else {
            $('#' + a + '-results').empty();
            var temp = _.template(
              $('#blast_template').html(), { 
                data: data,
                algo: a
              }
            );
            $('#' + a + '-results').html(temp);
            return;
          }
        } 
      );
    });
  },
  
  //
  // Display jQuery UI modal box containing detailed report of all hits 
  // to the same query. After the modal box is inserted into the DOM,
  // automatically scroll to the highlighted hit.
  //
  viewDetailedReport: function(id, focus_id, query, algo) {
    // Create the modal box.
    $('#detailed_report_dialog').html(
      "<p class='center'>" + 
      "Loading... <img src='/assets/quorum/loading.gif' alt='Loading'>" +
      "</p>"
    ).dialog({
      modal:    true,
      width:    850,
      position: 'top'
    });
  
    $.getJSON(
      '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + algo + 
      '&query=' + query,
      function(data) {
        var temp = _.template(
          $('#detailed_report_template').html(), {
            data:  data,
            query: query,
            algo:  algo
          }
        );
        
        // Insert the detailed report data.
        $('#detailed_report_dialog').empty().html(temp);
  
        // Add tipsy to the sequence data.
        $('a[rel=quorum-tipsy]').tipsy({ gravity: 's' });
        
        // Highlight the selected id.
        $('#' + focus_id).addClass("ui-state-highlight");
        
        // Automatically scroll to the selected id.
        QUORUM.autoScroll(focus_id, false);
      }
    );  
  },
  
  //
  // Helper to add title sequence position attribute for tipsy.
  //
  // If from > to decrement index; otherwise increment.
  // If the algo is tblastn and type is hit OR algo is blastx and type is query, 
  // increment / decrement by 3; otherwise increment / decrement by 1.
  //
  addBaseTitleIndex: function(bases, from, to, algo, type) {
    var forward = true;
    var value   = 1;
    var index   = from;
  
    if (from > to) {
      forward = false;
    }
  
    // Set value to 3 for the below.
    if ((type === "hit" && algo === "tblastn") ||
        (type === "query" && algo === "blastx")) {
      value = 3;
    }
  
    // Add tipsy to each base.
    return _.map(bases.split(''), function(c) {
      var str = "<a rel='quorum-tipsy' title=" + index + ">" + c + "</a>";
      forward ? index += value : index -= value;
      return str;
    }).join(''); 
  },
  
  //
  // Format sequence data for detailed report. 
  //
  // If q_from > q_to or h_from > h_to, subtract by increment; otherwise add
  // by increment.
  //
  // If algo is tblastn or blastx, multiple increment by 3.
  //
  formatSequenceReport: function(qseq, midline, hseq, q_from, q_to, h_from, h_to, algo) {
    var max       = qseq.length; // max length
    var increment = 60;          // increment value
    var s         = 0;           // start position
    var e         = increment;   // end position
    var seq       = "\n";        // seq string to return
  
    while(true) {
      seq += "qseq " + QUORUM.addBaseTitleIndex(qseq.slice(s, e), q_from, q_to, algo, 'query') + "\n";
      seq += "     " + midline.slice(s, e) + "\n";
      seq += "hseq " + QUORUM.addBaseTitleIndex(hseq.slice(s, e), h_from, h_to, algo, 'hit') + "\n\n";
  
      if (e >= max) {
        break;
      }
  
      s += increment;
      e += increment;
  
      // If the algorithm is blastx, increment * 3 only for qseq.
      if (algo === "blastx") {
        q_from < q_to ? q_from += (increment * 3) : q_from -= (increment * 3);
      } else {
        q_from < q_to ? q_from += increment : q_from -= increment;
      }
  
      // If the algorithm is tblastn, increment * 3 only for hseq.
      if (algo === "tblastn") {
        h_from < h_to ? h_from += (increment * 3) : h_from -= (increment * 3);
      } else {
        h_from < h_to ? h_from += increment : h_from -= increment;
      }
    }
    return "<p class='small'>Alignment (Mouse over for positions):</p>" + 
      "<span class='small'><pre>" + seq + "</pre></span>";
  },
  
  //
  // Format Query and Hit Strand.
  //
  // If query_frame or hit_frame < 0, print 'reverse'; print 'forward' otherwise.
  //
  formatStrand: function(qstrand, hstrand) {
    var q = "";
    var h = "";
  
    qstrand < 0 ? q = "reverse" : q = "forward";
    hstrand < 0 ? h = "reverse" : h = "forward";
  
    return q + " / " + h;
  },
  
  //
  // Display links to Hsps in the same group.
  //
  displayHspLinks: function(focus, group, data) {
    if (group !== null) {
      var str = "Related <a onclick=\"(QUORUM.openWindow(" + 
        "'http://www.ncbi.nlm.nih.gov/books/NBK62051/def-item/blast_glossary.HSP'," + 
        "'HSP', 800, 300))\">HSPs</a>: ";
  
      var ids = _.map(group.split(","), function(i) { return parseInt(i, 10); });
    
      var selected = _(data).chain()
        .reject(function(d) { return !_.include(ids, d.id); })
        .sortBy(function(d) { return d.id; })
        .value();
  
      _.each(selected, function(e) {
        if (e.id !== focus) {
          str += "<a onclick='(QUORUM.autoScroll(" + e.id + ", true))'>" + e.hsp_num + "</a> ";
        } else {
          str += e.hsp_num + " ";
        }
      });
      return str;
    }
  },
  
  //
  // Download Blast hit sequence.
  //
  downloadSequence: function(id, algo_id, algo, el) {
    $(el).html('Fetching sequence...');
  
    $.getJSON(
      "/quorum/jobs/" + id + "/get_quorum_blast_hit_sequence.json?algo_id=" +
      algo_id + "&algo=" + algo,
      function(data) {
        QUORUM.getSequenceFile(id, data[0].meta_id, el);
      }
    );
  },
  
  //
  // Poll application for Blast hit sequence.
  //
  getSequenceFile: function(id, meta_id, el) {
    var url = "/quorum/jobs/" + id + 
      "/send_quorum_blast_hit_sequence?meta_id=" + meta_id;
    $.get(
      url,
      function(data) {
        if (data.length === 0) {
          setTimeout(function() { QUORUM.getSequenceFile(id, meta_id, el) }, 2500);
        } else {
          if (data.indexOf("error") !== -1) {
            // Print error message.
            $(el).addClass('ui-state-error').html(data);  
          } else {
            // Force browser to download file via iframe.
            $(el).addClass('ui-state-highlight').html('Sequence Downloaded Successfully');  
            $('.quorum_sequence_download').remove();
            $('body').append('<iframe class="quorum_sequence_download"></iframe>');
            $('.quorum_sequence_download').attr('src', url).hide();
          }
        }
      } 
    );
  },
  
  //
  // Autoscroll to given div id.
  //
  autoScroll: function(id, highlight) {
    $('html, body').animate({
      scrollTop: $('#' + id).offset().top
    }, 1000);
  
    if (highlight) {
      $('#' + id).effect("highlight", {}, 4000);
    }
  },
  
  //
  // Open URL in new window.
  //
  openWindow: function(url, name, width, height) {
  
    var windowSize = "width=" + width + ",height=" + height + ",scrollbars=yes";
  
    window.open(url, name, windowSize);
  }

};

