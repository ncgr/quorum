module Quorum
  class JobQueueService

    #
    # Queue search workers.
    #
    def self.queue_search_workers(job)
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
            j,
            Quorum.blast_remote,
            Quorum.blast_ssh_host,
            Quorum.blast_ssh_user,
            Quorum.blast_ssh_options
          )
        end
      end
    end

    #
    # Queue fetch worker to send blast hit sequence. Return job meta_id for
    # for data access.
    #
    # See JobsController#send_blast_hit_sequence for more info.
    #
    def self.queue_fetch_worker(fetch_data)
      unless fetch_data.valid?
        return nil
      end

      cmd = Workers::System.create_blast_fetch_command(
        fetch_data.blast_dbs,
        fetch_data.hit_id,
        fetch_data.hit_display_id,
        fetch_data.algo
      )

      data = Workers::System.enqueue(
        cmd,
        Quorum.blast_remote,
        Quorum.blast_ssh_host,
        Quorum.blast_ssh_user,
        Quorum.blast_ssh_options,
        true
      )

      [{ meta_id: data.meta_id }]
    end

  end
end
