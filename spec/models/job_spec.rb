require 'spec_helper'

describe Quorum::Job do

  before(:each) do
    @job = Quorum::Job.new()
    ResqueSpec.reset!
  end

  it "fails validation without params" do
    @job.should have(1).error_on(:sequence)
    @job.should have(1).error_on(:algorithm)
  end

  it "passes validation with algorithm and valid sequence data" do
    @job.sequence = File.open(
      File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
    ).read
    @job.build_blastn_job
    @job.blastn_job.queue = true
    @job.should have(0).errors_on(:sequence)
    @job.should have(0).errors_on(:algorithm)
  end

  it "queues workers after save" do
    @job.sequence = File.open(
      File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
    ).read

    @job.build_blastn_job
    @job.blastn_job.queue     = true
    @job.blastn_job.blast_dbs = ["test_1", "test_2"]

    @job.save!

    Workers::System.should have_queue_size_of(1)
  end

end
