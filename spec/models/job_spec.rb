require 'spec_helper'

describe Quorum::Job do

  before(:each) do
    @job = Quorum::Job.new()
  end

  it "fails validation without params" do
    @job.should have(1).error_on(:sequence)
    @job.should have(1).error_on(:algorithm)
  end

  it "fails validation when input sequence size is too large" do
    @job.sequence = ">header\n" << "a" * 51200
    @job.build_blastn_job
    @job.blastn_job.queue = true
    @job.should have(1).errors_on(:sequence)
  end

  it "fails validation with invalid sequence data" do
    @job.sequence = File.open(
      File.expand_path("../../data/seqs_not_fa.txt", __FILE__)
    ).read
    @job.build_blastn_job
    @job.blastn_job.queue = true
    @job.should have(1).errors_on(:sequence)
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

  it "deletes completed jobs" do
    1.upto(5) do |i|
      job = Quorum::Job.new()
      job.sequence = File.open(
        File.expand_path("../../data/nucl_prot_seqs.txt", __FILE__)
      ).read

      job.build_blastn_job
      job.blastn_job.queue     = true
      job.blastn_job.blast_dbs = ["test"]

      job.created_at = i.weeks.ago
      job.save!
    end
    Quorum::Job.delete_jobs("25 days").count.should eq(2)
    Quorum::BlastnJob.count.should eq(3)
  end

end
