module Quorum
  class JobQueueService

    #
    # Queue search workers.
    #
    def self.queue_search_workers(job)
      blast_jobs = []
      if job.blastn_job && job.blastn_job.queue
        blast_jobs << Workers::System.create_search_command("blastn", job.id)
      end
      if job.blastx_job && job.blastx_job.queue
        blast_jobs << Workers::System.create_search_command("blastx", job.id)
      end
      if job.tblastn_job && job.tblastn_job.queue
        blast_jobs << Workers::System.create_search_command("tblastn", job.id)
      end
      if job.blastp_job && job.blastp_job.queue
        blast_jobs << Workers::System.create_search_command("blastp", job.id)
      end

      unless blast_jobs.blank?
        blast_jobs.each do |b|
          Workers::System.enqueue(
            b,
            Quorum.blast_remote,
            Quorum.blast_ssh_host,
            Quorum.blast_ssh_user,
            Quorum.blast_ssh_options
          )
        end
      end

      gmap_jobs = []
      if job.gmap_job && job.gmap_job.queue
        gmap_jobs << Workers::System.create_search_command("gmap", job.id)
      end

      unless gmap_jobs.blank?
        gmap_jobs.each do |g|
          Workers::System.enqueue(
            g,
            Quorum.gmap_remote,
            Quorum.gmap_ssh_host,
            Quorum.gmap_ssh_user,
            Quorum.gmap_ssh_options
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
