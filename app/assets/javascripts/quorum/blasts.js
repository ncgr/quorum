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

  var blast_options_empty = true;
  $('#blast-options :input').each(function(index, elem) {
    if ($(elem).val() !== '' && $(elem).val() !== 'false') {
      blast_options_empty = false;
    }
  });

  // Hide blast options if they are empty.
  if (blast_options_empty) {
    $('#blast-options').hide();
  }

  // Hide if blast_gapped_alignments is false.
  if ($('#blast_gapped_alignments').val() === 'false') {
    $('#gap-extras').hide();
  }

  // Toggle hidden elements.
  $('#options').click(function() {
    $('#blast-options').slideToggle();
  });

  $('#blast_gapped_alignments').change(function() {
    if ($('#blast_gapped_alignments').val() === 'true') {
      $('#gap-extras').slideDown();
    } else {
      $('#gap-extras').slideUp();
    }
  });

  // End Elements //


  // Form //

  var form = $('form :input.auto-hint');
  form.focusHint();
  form.blurHint();
  form.addHints();

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
  $('#quorum_blast_reset').click(function() {
    $('#quorum_blast :input[type=text]').each(function(index, elem) {
      $(elem).val('');
    });
    $('#blast_sequence_file').val('');
    $('#blast_sequence').val('');
    $('#blast_gapped_alignments').val('false');
    $('#blast_gap_opening_extension').val('');
    form.addHints();
  });

  // End Form //

});
