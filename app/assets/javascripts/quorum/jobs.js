//
// jQuery
//---------------------------------------------------------------------------//

$(function() {

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

  if (!$('#job_tblastx_job_attributes_queue').is(':checked')) {
    $('#tblastx').hide();
  }

  // End Elements //


  // Form //

  var form = $('form :input.auto-hint');
  form.autoHint();

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

  $('#job_tblastx_job_attributes_queue').change(function() {
    $('#tblastx').slideToggle();
  });

  // End Algorithms //

  // Disable submit button and remove input values equal to attr title.
  $('form').submit(function() {
    $('input[type=submit]', this).val('Processing...').attr(
      'disabled', 'disabled'
    );

    form.autoHint('removeHints');
  });

  $(window).unload(function() {
    $('input[type=submit]', 'form').val('Submit').removeAttr('disabled');
  });

  // Reset form.
  $('#quorum_job_reset').click(function() {
    $('textarea').val('');
    $('input:text').val('');
    $('input:file').val('');
    $('input:checkbox').prop('checked', false);
    $('select').val('');

    $('.toggle').each(function() {
      $(this).hide();
    });

    form.autoHint('addHints');
  });

  // End Form //


  // Views //

  // Tabs
  $('#tabs').tabs();

  // End Views //

});

