$(function() {

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

  // Disable submit button and display gif.
  // Remove input values equal to attr title.
  $('form').submit(function() {
    $('input[type=submit]', this).val(
      'Michael Knight, a lone crusader in a dangerous world. ' + 
      'The world... of the Knight Rider.'
      ).attr('disabled', 'disabled'
    );
    $('#loading').show();
    $('form :input.auto-hint').each(function() {
      if ($(this).val() === $(this).attr('title')) { 
        $(this).val(''); 
      }     
    });  
  });

  // Reset form.
  $('#quorum_blast_reset').click(function() {
    $('#quorum_blast :input[type=text]').each(function(index, elem) {
      $(elem).val('');
    });
    $('#blast_sequence_file').val('');
    $('#blast_sequence').val('');
    $('#blast_gapped_alignments').val('false');
  });

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

  // Add form hints
  $('form :input.auto-hint').focus(function() {
    if ($(this).val() === $(this).attr('title')) {
      $(this).val('');
      $(this).removeClass('auto-hint');
    }
  });

  $('form :input.auto-hint').blur(function() {
    if ($(this).val() === '' && $(this).attr('title') !== '') {
       $(this).val($(this).attr('title'));
       $(this).addClass('auto-hint');
    }
  });

  $('form :input.auto-hint').each(function() {
    if ($(this).attr('title') === '') { 
      return; 
    }
    if ($(this).val() === '') { 
      $(this).val($(this).attr('title')); 
    } else { 
      $(this).removeClass('auto-hint'); 
    }
  });  

});
