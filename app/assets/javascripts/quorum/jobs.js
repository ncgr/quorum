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
  $('#blastn').hide();
  $('#blastx').hide();
  $('#tblastn').hide();
  $('#blastp').hide();
  $('#hmmer').hide();

  // End Elements //


  // Form //

  var form = $('form :input.auto-hint');
  form.focusHint();
  form.blurHint();
  form.addHints();

  // Toggle Algorithms //

  $('#activate_blastn').change(function() {
    $('#blastn').slideToggle();
  });

  $('#activate_blastx').change(function() {
    $('#blastx').slideToggle();
  });

  $('#activate_tblastn').change(function() {
    $('#tblastn').slideToggle();
  });

  $('#activate_blastp').change(function() {
    $('#blastp').slideToggle();
  });

  $('#activate_hmmer').change(function() {
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
    $('#quorum_job :input[type=text]').each(function(index, elem) {
      $(elem).val('');
    });
    $('#job_sequence_file').val('');
    $('#job_sequence').val('');
    form.addHints();
  });

  // End Form //

});
