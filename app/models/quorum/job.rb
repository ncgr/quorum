module Quorum
  class Job < ActiveRecord::Base

    include Quorum::Sequence

    after_save :queue_workers

    has_one :blastn_job, :dependent => :destroy
    has_many :blastn_job_reports, :through => :blastn_job,
      :dependent => :destroy

    has_one :blastx_job, :dependent => :destroy
    has_many :blastx_job_reports, :through => :blastx_job,
      :dependent => :destroy

    has_one :tblastn_job, :dependent => :destroy
    has_many :tblastn_job_reports, :through => :tblastn_job,
      :dependent => :destroy

    has_one :blastp_job, :dependent => :destroy
    has_many :blastp_job_reports, :through => :blastp_job,
      :dependent => :destroy

    has_one :tblastx_job, :dependent => :destroy
    has_many :tblastx_job_reports, :through => :tblastx_job,
      :dependent => :destroy

    accepts_nested_attributes_for :blastn_job, :blastx_job, :tblastn_job,
      :blastp_job, :tblastx_job,
      :reject_if => proc { |attributes| attributes['queue'] == '0' }

    attr_accessible :sequence, :na_sequence, :aa_sequence,
      :blastn_job_attributes, :blastx_job_attributes, :tblastn_job_attributes,
      :blastp_job_attributes, :tblastx_job_attributes

    validates_associated :blastn_job, :blastx_job, :tblastn_job, :blastp_job,
      :tblastx_job

    validate :filter_input_sequences, :algorithm_selected, :sequence_size

    #
    # Fetch Blast hit_id, hit_display_id, queue Resque worker and
    # return worker's meta_id.
    #
    def fetch_quorum_blast_sequence(algo, algo_id)
      job         = "#{algo}_job".to_sym
      job_reports = "#{algo}_job_reports".to_sym

      blast_dbs = self.method(job).call.blast_dbs

      job_report = self.method(job_reports).call.where(
        "quorum_#{algo}_job_reports.id = ?", algo_id
      ).first

      hit_id          = job_report.hit_id
      hit_display_id  = job_report.hit_display_id

      cmd = Workers::System.create_blast_fetch_command(
        blast_dbs, hit_id, hit_display_id, algo
      )

      data = Workers::System.enqueue(
        cmd, Quorum.blast_remote,
        Quorum.blast_ssh_host, Quorum.blast_ssh_user,
        Quorum.blast_ssh_options, true
      )

      Workers::System.get_meta(data.meta_id)
    end

    #
    # Delete submitted jobs.
    #
    def self.delete_jobs(time = 1.week)
      if time.is_a?(String)
        time = time.split.inject { |count, unit| count.to_i.send(unit) }
      end

      self.where("created_at < '#{time.ago.to_s(:db)}'").delete_all
    end

    private

    #
    # Filter input sequences by type (AA or NA) and place each in it's
    # appropriate attribute.
    #
    def filter_input_sequences
      # Ensure the sequences are in plain text.
      begin
        ActiveSupport::Multibyte::Unicode.u_unpack(self.sequence)
      rescue ActiveSupport::Multibyte::EncodingError => e
        logger.error e.message
        errors.add(
          :sequence,
          "Please enter your sequence(s) in Plain Text as FASTA."
        )
        self.sequence = ""
        return
      end

      hash = create_hash(self.sequence)
      tmp  = File.join(::Rails.root.to_s, 'tmp')

      # Ensure the sequences are FASTA via #write_input_sequence_to_file.
      begin
        write_input_sequence_to_file(tmp, hash, self.sequence)
      rescue Exception => e
        errors.add(:sequence, e.message)
        return
      else
        fasta = File.read(File.join(tmp, hash + ".fa"))
      ensure
        File.delete(File.join(tmp, hash + ".fa"))
        File.delete(File.join(tmp, hash + ".seq"))
      end

      self.na_sequence = ""
      self.aa_sequence = ""

      # Split the sequences on >, check the type (AA or NA) and separate.
      seqs = fasta.split('>')
      seqs.delete_if { |s| s.empty? }
      seqs.each do |s|
        type = discover_input_sequence_type(s)
        if type == "nucleic_acid"
          self.na_sequence << ">" << s
        end
        if type == "amino_acid"
          self.aa_sequence << ">" << s
        end
      end

      self.na_sequence = nil if self.na_sequence.empty?
      self.aa_sequence = nil if self.aa_sequence.empty?
    end

    #
    # Make sure an algorithm is selected.
    #
    def algorithm_selected
      in_queue = false
      if (self.blastn_job && self.blastn_job.queue) ||
        (self.blastx_job && self.blastx_job.queue) ||
        (self.tblastn_job && self.tblastn_job.queue) ||
        (self.blastp_job && self.blastp_job.queue) ||
        (self.tblastx_job && self.tblastx_job.queue)
        in_queue = true
      end
      unless in_queue
        errors.add(
          :algorithm,
          " - Please select at least one algorithm to continue."
        )
      end
    end

    #
    # Validate input sequence size.
    #
    # Defaults to 50 KB. See lib/quorum.rb.
    #
    def sequence_size
      if self.sequence.size > Quorum.max_sequence_size
        errors.add(
          :sequence,
          " - Input sequence size too large. " <<
          "Max size: #{Quorum.max_sequence_size / 1024} KB"
        )
      end
    end

    #
    # Queue Resque workers.
    #
    def queue_workers
      jobs = []
      if self.blastn_job && self.blastn_job.queue
        jobs << Workers::System.create_search_command("blastn", self.id)
      end
      if self.blastx_job && self.blastx_job.queue
        jobs << Workers::System.create_search_command("blastx", self.id)
      end
      if self.tblastn_job && self.tblastn_job.queue
        jobs << Workers::System.create_search_command("tblastn", self.id)
      end
      if self.blastp_job && self.blastp_job.queue
        jobs << Workers::System.create_search_command("blastp", self.id)
      end
      if self.tblastx_job && self.tblastx_job.queue
        jobs << Workers::System.create_search_command("tblastx", self.id)
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
