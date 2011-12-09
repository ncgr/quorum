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

  $('#loading').hide();

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

  // Disable submit button and display gif.
  // Remove input values equal to attr title.
  $('form').submit(function() {
    $('input[type=submit]', this).val('Processing...').attr(
      'disabled', 'disabled'
    );
    $('#loading').show();
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
// Poll quorum search results asynchronously and insert them into
// the DOM via #blast_template.
//
var pollResults = function(id, algo) {
  _.each(algo, function(a) {
	  $.getJSON(
	    '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + a,
	    function(data) {
	      if (data.length === 0) {
	        setTimeout(function() { pollResults(id, algo); }, 1500);
	      } else {
	        switch(a) {
	          case "blastn":
	            $('#blastn-results').empty();
	            var temp = _.template(
	              $('#blast_template').html(), { 
	                data: data,
	                algo: a
	              }
	            );
	            $('#blastn-results').html(temp);
	            break;
	          case "blastx":
	            $('#blastx-results').empty();
	            var temp = _.template(
	              $('#blast_template').html(), { 
	                data: data,
	                algo: a
	              }
	            );
	            $('#blastx-results').html(temp);
	            break;
	          case "tblastn":
	            $('#tblastn-results').empty();
	            var temp = _.template(
	              $('#blast_template').html(), { 
	                data: data,
	                algo: a
	              }
	            );
	            $('#tblastn-results').html(temp);
	            break;
	          case "blastp":
	            $('#blastp-results').empty();
	            var temp = _.template(
	              $('#blast_template').html(), { 
	                data: data,
	                algo: a
	              }
	            );
	            $('#blastp-results').html(temp);
	            break;
	          case "hmmer":
	            $('#hmmer-results').empty();
	            var temp = _.template(
	              $('#blast_template').html(), { 
	                data: data,
	                algo: a
	              }
	            );
	            $('#hmmer-results').html(temp);
	            break;
	        }
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
      $('a[rel=quorum-tipsy]').tipsy({gravity: 's'});
      
      // Highlight the selected id.
      $('#' + focus_id).addClass("ui-state-highlight");
      
      // Automatically scroll to the selected id.
      $('html, body').animate({
        scrollTop: $('#' + focus_id).offset().top
      }, 1000);
    }
  );  
}

//
// Helper to add title sequence position attribute for tipsy.
//
// If from > to decrement index; otherwise increment.
// If the algo is tblastn and hseq is true, increment / decrement 
// by 3; otherwise increment / decrement by 1.
//
var addBaseTitleIndex = function(bases, from, to, algo, hseq) {
  var forward = true;
  var value   = 1;
  var index   = from;

  if (from > to) {
    forward = false;
  }

  // Only set value to 3 if hseq is true and algo is tblastn.
  if (hseq && (algo === "tblastn")) {
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
// If algo is tblastn, multiple increment by 3.
//
var formatSequenceReport = function(qseq, midline, hseq, q_from, q_to, h_from, h_to, algo) {
  var max       = qseq.length; // max length
  var increment = 60;          // increment value
  var s         = 0;           // start position
  var e         = increment;   // end position
  var seq       = "\n";        // seq string to return

  while(true) {
    seq += "qseq " + addBaseTitleIndex(qseq.slice(s, e), q_from, q_to, algo, false) + "\n";
    seq += "     " + midline.slice(s, e) + "\n";
    seq += "hseq " + addBaseTitleIndex(hseq.slice(s, e), h_from, h_to, algo, true) + "\n\n";

    if (e >= max) {
      break;
    }

    s += increment;
    e += increment;

    // Check the forward / reverse nature of the sequence.
    q_from < q_to ? q_from += increment : q_from -= increment;
    // If the algorithm is tblastn, increment * 3 only for hseq.
    if (algo === "tblastn") {
      increment = (increment * 3);
    }
    h_from < h_to ? h_from += increment : h_from -= increment;
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

