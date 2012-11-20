module Quorum
  class JobQueueService

    #
    # Queue Resque workers.
    #
    def self.queue_workers(job)
      jobs = []
      if job.blastn_job && job.blastn_job.queue
        jobs << Workers::System.create_search_command("blastn", job.id)
      end
      if job.blastx_job && job.blastx_job.queue
        jobs << Workers::System.create_search_command("blastx", job.id)
      end
      if job.tblastn_job && job.tblastn_job.queue
        jobs << Workers::System.create_search_command("tblastn", job.id)
      end
      if job.blastp_job && job.blastp_job.queue
        jobs << Workers::System.create_search_command("blastp", job.id)
      end

      unless jobs.blank?
        jobs.each do |j|
          Workers::System.enqueue(
            j, Quorum.blast_remote,
            Quorum.blast_ssh_host, Quorum.blast_ssh_user,
            Quorum.blast_ssh_options
          )
        end
      end
    end

  end
end
