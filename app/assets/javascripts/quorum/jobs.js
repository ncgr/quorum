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
// Poll quorum search results asynchronously
//
var pollResults = function(id, algo) {
  _.each(algo, function(a) {
	  $.getJSON(
	    '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + a,
	    function(data) {
	      if (data.length === 0) {
	        setTimeout(function() { pollResults(id, algo); }, 900);
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
// Display jQuery-UI Modal Box containing detailed report of hit plus
// other hits to the same query.
//
var viewDetailedReport = function(id, focus_id, query, algo) {
  $.getJSON(
    '/quorum/jobs/' + id + '/get_quorum_search_results.json?algo=' + algo + 
    '&query=' + query,
    function(data) {
      var temp = _.template(
        $('#detailed_report_template').html(), {
          data: data,
          query: query
        }
      );
      $('#detailed_report_dialog').html(temp).dialog({
        modal:    true,
        width:    850,
        position: 'top'
      });
      // Add tipsy to the sequence data.
      $('a[rel=quorum-tipsy]').tipsy({gravity: 's'});
    }
  );  
}

//
// Helper to add title attribute for tipsy.
//
var addBaseTitleIndex = function(bases, index) {
  return _.map(bases, function(c) {
    return "<a rel='quorum-tipsy' title=" + index++ + ">" + c + "</a>"
  }).join(''); 
}

//
// Make sequence report data look pretty. 
//
var formatSequenceReport = function(qseq, midline, hseq, q_from, h_from) {
  var max       = qseq.length;
  var increment = 60;

  var s   = 0;
  var e   = increment;
  var seq = "\n";

  while(true) {
    if (e >= max) {
      seq += "qseq " + addBaseTitleIndex(qseq.slice(s, max).split(''), q_from) + "\n";
      seq += "     " + midline.slice(s, max) + "\n";
      seq += "hseq " + addBaseTitleIndex(hseq.slice(s, max).split(''), h_from) + "\n\n";
      break;
    }
    seq += "qseq " + addBaseTitleIndex(qseq.slice(s, e).split(''), q_from) + "\n";
    seq += "     " + midline.slice(s, e) + "\n";
    seq += "hseq " + addBaseTitleIndex(hseq.slice(s, e).split(''), h_from) + "\n\n";

    s += increment;
    e += increment;

    q_from += increment;
    h_from += increment;
  }
  return "<p class='small'>Sequence:</p><pre>" + seq + "</pre>";
}

