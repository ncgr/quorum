//
// Quorum Job Views
//

describe("Quorum Search Form", function() {

  beforeEach(function() {
    loadFixtures('quorum_search_form.html');
  });

  it("toggles algorithm queues on change", function() {
    spyOnEvent($("#job_blastn_job_attributes_queue"), 'change');
    spyOnEvent($("#job_blastx_job_attributes_queue"), 'change');
    spyOnEvent($("#job_tblastn_job_attributes_queue"), 'change');
    spyOnEvent($("#job_blastp_job_attributes_queue"), 'change');
    spyOnEvent($("#job_gmap_job_attributes_queue"), 'change');

    $('#job_blastn_job_attributes_queue').change();
    expect('change').toHaveBeenTriggeredOn($('#blastn'));

    $('#job_blastx_job_attributes_queue').change();
    expect('change').toHaveBeenTriggeredOn($('#blastx'));

    $('#job_tblastn_job_attributes_queue').change();
    expect('change').toHaveBeenTriggeredOn($('#tblastn'));

    $('#job_blastp_job_attributes_queue').change();
    expect('change').toHaveBeenTriggeredOn($('#blastp'));

    $('#job_gmap_job_attributes_queue').change();
    expect('change').toHaveBeenTriggeredOn($('#gmap'));
  });

  it("hides intron fields when splicing is false", function() {
    spyOnEvent($("#job_gmap_job_attributes_splicing"), 'change');
    $('#job_gmap_job_attributes_splicing').change();
    expect('change').toHaveBeenTriggeredOn($('.intron'));
  });

  it("resets form", function() {
    spyOnEvent($('#quorum_job_reset'), 'click');
    $('#quorum_job_reset').click();
    expect('click').toHaveBeenTriggeredOn($('textarea'));
    expect('click').toHaveBeenTriggeredOn($('input:text'));
    expect('click').toHaveBeenTriggeredOn($('input:file'));
    expect('click').toHaveBeenTriggeredOn($('input:checkbox'));
    expect('click').toHaveBeenTriggeredOn($('select'));
  });

  it("inserts form hints", function() {
    $('form :input.auto-hint').autoHint();
    expect($('#job_sequence')).toHaveValue($('#job_sequence').attr('title'));

    expect($('#job_blastn_job_attributes_expectation')).toHaveValue(
      $('#job_blastn_job_attributes_expectation').attr('title')
    );
    expect($('#job_blastx_job_attributes_expectation')).toHaveValue(
      $('#job_blastx_job_attributes_expectation').attr('title')
    );
    expect($('#job_tblastn_job_attributes_expectation')).toHaveValue(
      $('#job_tblastn_job_attributes_expectation').attr('title')
    );
    expect($('#job_blastp_job_attributes_expectation')).toHaveValue(
      $('#job_blastp_job_attributes_expectation').attr('title')
    );

    expect($('#job_blastn_job_attributes_min_bit_score')).toHaveValue(
      $('#job_blastn_job_attributes_min_bit_score').attr('title')
    );
    expect($('#job_blastx_job_attributes_min_bit_score')).toHaveValue(
      $('#job_blastx_job_attributes_min_bit_score').attr('title')
    );
    expect($('#job_tblastn_job_attributes_min_bit_score')).toHaveValue(
      $('#job_tblastn_job_attributes_min_bit_score').attr('title')
    );
    expect($('#job_blastp_job_attributes_min_bit_score')).toHaveValue(
      $('#job_blastp_job_attributes_min_bit_score').attr('title')
    );

    expect($('#job_blastn_job_attributes_max_target_seqs')).toHaveValue(
      $('#job_blastn_job_attributes_max_target_seqs').attr('title')
    );
    expect($('#job_blastx_job_attributes_max_target_seqs')).toHaveValue(
      $('#job_blastx_job_attributes_max_target_seqs').attr('title')
    );
    expect($('#job_tblastn_job_attributes_max_target_seqs')).toHaveValue(
      $('#job_tblastn_job_attributes_max_target_seqs').attr('title')
    );
    expect($('#job_blastp_job_attributes_max_target_seqs')).toHaveValue(
      $('#job_blastp_job_attributes_max_target_seqs').attr('title')
    );
  });

});

describe("Quorum Search Results", function() {

  beforeEach(function() {
    loadFixtures('quorum_tabs.html');
  });

  it("displays results in tabs", function() {
    $('#tabs').tabs();
    expect($('#tabs-1')).not.toHaveClass('ui-tabs-hide');
    expect($('#tabs-2')).toHaveClass('ui-tabs-hide');
    expect($('#tabs-3')).toHaveClass('ui-tabs-hide');
  });

});
