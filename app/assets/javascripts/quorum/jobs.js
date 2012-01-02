//
// Mustache style Underscore.js templating.
//
_.templateSettings = {
  evaluate: /\{\{(.+?)\}\}/g,
  interpolate: /\{\{\=(.+?)\}\}/g
};

//
// jQuery
//---------------------------------------------------------------------------//

$(function() {

  // jQuery Functions //

  $.fn.extend({
    // Add hints to the form elements.
    addHints: function() {
      $(this).each(function() {
        if ($(this).attr('title') === '') { 
          return; 
        }

        if ($(this).val() === '') { 
          $(this).val($(this).attr('title')); 

          if (!$(this).hasClass('auto-hint')) {
            $(this).addClass('auto-hint');
          }
        } else { 
          $(this).removeClass('auto-hint'); 
        }
      });          
    },

    // Remove hints on submit.
    removeHintsOnSubmit: function() {
      $(this).each(function() {
        if ($(this).val() === $(this).attr('title')) { 
          $(this).val(''); 
        }     
      });                      
    },

    // Remove hint and class on focus.
    focusHint: function() {
      $(this).focus(function() {
        if ($(this).val() === $(this).attr('title')) {
          $(this).val('');
          $(this).removeClass('auto-hint');
        }
      });               
    },

    // Retain value or add hint.
    blurHint: function() {
      $(this).blur(function() {
        if ($(this).val() === '' && $(this).attr('title') !== '') {
          $(this).val($(this).attr('title'));
          $(this).addClass('auto-hint');
        }
      });     
    }
  });

  // End jQuery Functions //


  // Hide Elements //

  if (!$('#job_blastn_job_attributes_queue').is(':checked')) {
    $('#blastn').hide();
  }

  if (!$('#job_blastx_job_attributes_queue').is(':checked')) {
    $('#blastx').hide();
  }

  if (!$('#job_tblastn_job_attributes_queue').is(':checked')) {
    $('#tblastn').hide();
  }

  if (!$('#job_blastp_job_attributes_queue').is(':checked')) {
    $('#blastp').hide();
  }

  if (!$('#job_hmmer_job_attributes_queue').is(':checked')) {
    $('#hmmer').hide();
  }

  // End Elements //


  // Form //

  var form = $('form :input.auto-hint');
  form.focusHint();
  form.blurHint();
  form.addHints();

  // Toggle Algorithms //

  $('#job_blastn_job_attributes_queue').change(function() {
    $('#blastn').slideToggle();
  });

  $('#job_blastx_job_attributes_queue').change(function() {
    $('#blastx').slideToggle();
  });

  $('#job_tblastn_job_attributes_queue').change(function() {
    $('#tblastn').slideToggle();
  });

  $('#job_blastp_job_attributes_queue').change(function() {
    $('#blastp').slideToggle();
  });

  $('#job_hmmer_job_attributes_queue').change(function() {
    $('#hmmer').slideToggle();
  });

  // End Algorithms //

  // Disable submit button and remove input values equal to attr title.
  $('form').submit(function() {
    $('input[type=submit]', this).val('Processing...').attr(
      'disabled', 'disabled'
    );

    form.removeHintsOnSubmit();
  });

  // Reset form.
  $('#quorum_job_reset').click(function() {
    $('input:text').val('');
    $('input:file').val('');
    $('input:checkbox').attr('checked', false);
    $('select').val('');

    $('.toggle').each(function() {
      $(this).hide();
    });

    form.addHints();
  });

  // End Form //

  
  // Views //
  
  // Tabs
  $('#tabs').tabs();

  // End Views //

});


//
// JavaScript Functions
//---------------------------------------------------------------------------// 

// 
// Poll quorum search results asynchronously and insert them into
// the DOM via #blast_template.
//
var pollResults = function(id, algo) {
  _.each(algo, function(a) {
    $.getJSON(
      '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + a,
      function(data) {
        if (data.length === 0) {
          setTimeout(function() { pollResults(id, algo); }, 2000);
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
}

//
// Display jQuery UI modal box containing detailed report of all hits 
// to the same query. After the modal box is inserted into the DOM,
// automatically scroll to the highlighted hit.
//
var viewDetailedReport = function(id, focus_id, query, algo) {
  // Create the modal box.
  $('#detailed_report_dialog').html(
    "<p class='center'>" + 
    "Loading... <img src='/assets/quorum/knight_rider.gif' alt='Loading'>" +
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
      autoScroll(focus_id, false);
    }
  );  
}

//
// Helper to add title sequence position attribute for tipsy.
//
// If from > to decrement index; otherwise increment.
// If the algo is tblastn and type is hit OR algo is blastx and type is query, 
// increment / decrement by 3; otherwise increment / decrement by 1.
//
var addBaseTitleIndex = function(bases, from, to, algo, type) {
  var forward = true;
  var value   = 1;
  var index   = from;

  if (from > to) {
    forward = false;
  }

  // Only set value to 3 if hseq is true and algo is tblastn.
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
}

//
// Format sequence data for detailed report. 
//
// If q_from > q_to or h_from > h_to, subtract by increment; otherwise add
// by increment.
//
// If algo is tblastn or blastx, multiple increment by 3.
//
var formatSequenceReport = function(qseq, midline, hseq, q_from, q_to, h_from, h_to, algo) {
  var max       = qseq.length; // max length
  var increment = 60;          // increment value
  var s         = 0;           // start position
  var e         = increment;   // end position
  var seq       = "\n";        // seq string to return

  while(true) {
    seq += "qseq " + addBaseTitleIndex(qseq.slice(s, e), q_from, q_to, algo, 'query') + "\n";
    seq += "     " + midline.slice(s, e) + "\n";
    seq += "hseq " + addBaseTitleIndex(hseq.slice(s, e), h_from, h_to, algo, 'hit') + "\n\n";

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
}

//
// Format Query and Hit Strand.
//
// If query_frame or hit_frame < 0, print 'reverse'; print 'forward' otherwise.
//
var formatStrand = function(qstrand, hstrand) {
  var q = "";
  var h = "";

  qstrand < 0 ? q = "reverse" : q = "forward";
  hstrand < 0 ? h = "reverse" : h = "forward";

  return q + " / " + h;
}

//
// Display links to Hsps in the same group.
//
var displayHspLinks = function(focus, group, data) {
  if (group !== null) {
    var str = "Related <a onclick=\"(openWindow(" + 
      "'http://www.ncbi.nlm.nih.gov/books/NBK62051/def-item/blast_glossary.HSP'," + 
      "'HSP', 800, 300))\">HSPs</a>: ";

    var ids = _.map(group.split(","), function(i) { return parseInt(i); });
  
    var selected = _(data).chain()
      .reject(function(d) { return !_.include(ids, d.id); })
      .sortBy(function(d) { return d.id; })
      .value();

    _.each(selected, function(e) {
      if (e.id !== focus) {
        str += "<a onclick='(autoScroll(" + e.id + ", true))'>" + e.hsp_num + "</a> ";
      } else {
        str += e.hsp_num + " ";
      }
    });
    return str;
  }
}

//
// Autoscroll to given div id.
//
var autoScroll = function(id, highlight) {
  $('html, body').animate({
    scrollTop: $('#' + id).offset().top
  }, 1000);

  if (highlight) {
    $('#' + id).effect("highlight", {}, 4000);
  }
}

//
// Truncate string to length n using word boundary.
//
String.prototype.trunc = function(n) {
  var longStr = this.length > n;
  var str     = longStr ? this.substr(0, n-1) : this;

  longStr ? str.substr(0, str.lastIndexOf(' ')) : str;
  return longStr ? str + '...' : str;
}

//
// Open URL in new window.
//
var openWindow = function(url, name, width, height) {

  var windowSize = "width=" + width + ",height=" + height + ",scrollbars=yes";

  window.open(url, name, windowSize);
}

