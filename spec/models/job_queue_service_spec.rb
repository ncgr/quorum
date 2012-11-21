require 'spec_helper'

describe Quorum::JobQueueService do

  before(:each) do
    ResqueSpec.reset!
  end

  describe "Job Queue" do

    before(:each) do
      @job = Quorum::Job.new()
      @job.sequence = File.open(
        File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      ).read
      @job.build_blastn_job
      @job.blastn_job.queue     = true
      @job.blastn_job.blast_dbs = ["db"]
      @job.save!
    end

    it "enqueues job after save" do
      Quorum::JobQueueService.queue_search_workers(@job)
      Workers::System.should have_queue_size_of(1)
    end

  end

  describe "Fetch Queue" do

    before(:each) do
      @fetch = Quorum::JobFetchData.new
      @fetch.algo           = "foo"
      @fetch.blast_dbs      = "foo"
      @fetch.hit_id         = "foo"
      @fetch.hit_display_id = "foo"
    end

    it "enqueues valid blast fetch and returns meta_id" do
      f = Quorum::JobQueueService.queue_fetch_worker(@fetch)
      Workers::System.should have_queue_size_of(1)
      f.should have(1).items
      f[0].keys.should eq([:meta_id])
      f[0].values.should_not be_empty
    end

  end

end
