require 'spec_helper'

describe Quorum::JobQueueObserver do

  it "should queue workers after create" do
    job = Quorum::Job.new()
    job.sequence = ">test\n" + "a" * 50
    job.build_blastn_job
    job.blastn_job.queue     = true
    job.blastn_job.blast_dbs = ["test"]

    obs = Quorum::JobQueueObserver.instance

    Quorum::JobQueueService.should_receive(:queue_search_workers).with(job)
    obs.after_create(job)
  end

end
