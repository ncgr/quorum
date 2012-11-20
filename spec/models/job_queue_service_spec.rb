require 'spec_helper'

describe Quorum::JobQueueService do

  before(:each) do
    @job = Quorum::Job.new()
    @job.sequence = File.open(
      File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
    ).read
    @job.build_blastn_job
    @job.blastn_job.queue     = true
    @job.blastn_job.blast_dbs = ["db"]
    @job.save!
    ResqueSpec.reset!
  end

  it "enqueues job after save" do
    Quorum::JobQueueService.queue_workers(@job)
    Workers::System.should have_queue_size_of(1)
  end

end
