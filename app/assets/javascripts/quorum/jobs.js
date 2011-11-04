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

});
