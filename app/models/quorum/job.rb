module Quorum
  class Job < ActiveRecord::Base

    include Quorum::Sequence

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

    accepts_nested_attributes_for :blastn_job, :blastx_job, :tblastn_job,
      :blastp_job,
      :reject_if => proc { |attributes| attributes['queue'] == '0' }

    attr_accessible :sequence, :na_sequence, :aa_sequence,
      :blastn_job_attributes, :blastx_job_attributes, :tblastn_job_attributes,
      :blastp_job_attributes

    validates_associated :blastn_job, :blastx_job, :tblastn_job, :blastp_job

    validate :filter_input_sequences, :algorithm_selected, :sequence_size

    #
    # Return search results (Resque worker results).
    #
    def self.search(params)
      data = JobData.new

      # Allow for multiple algos and search params.
      # Ex: /quorum/jobs/:id/search?algo=blastn,blastp
      if params[:algo]
        params[:algo].split(",").each do |a|
          if Quorum::SUPPORTED_ALGORITHMS.include?(a)
            enqueued = "#{a}_job".to_sym
            report   = "#{a}_job_reports".to_sym
            begin
              job = Job.find(params[:id])
            rescue ActiveRecord::RecordNotFound => e
              logger.error e.message
            else
              if job.try(enqueued).present?
                if job.try(report).present?
                  data.results << job.try(report).search(params).default_order
                else
                  data = JobData.new
                end
              else
                data.not_enqueued
              end
            end
          end
        end
      else
        data.no_results
      end

      data.results
    end

    #
    # Fetch Blast hit_id, hit_display_id, queue Resque worker and
    # return worker's meta_id.
    #
    def self.set_blast_hit_sequence_lookup_values(params)
      fetch_data   = JobFetchData.new
      algo         = params[:algo]
      algo_id      = params[:algo_id]

      if Quorum::SUPPORTED_ALGORITHMS.include?(algo)
        fetch_data.algo = algo
        begin
          job = Job.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          logger.error e.message
        else
          algo_job         = "#{algo}_job".to_sym
          algo_job_reports = "#{algo}_job_reports".to_sym

          fetch_data.blast_dbs = job.try(algo_job).blast_dbs

          job_report = job.try(algo_job_reports).where(
            "quorum_#{algo}_job_reports.id = ?", algo_id
          ).first

          fetch_data.hit_id          = job_report.hit_id
          fetch_data.hit_display_id  = job_report.hit_display_id
        end
      end
      fetch_data
    end

    #
    # Delete submitted jobs.
    #
    def self.delete_jobs(time = 1.week)
      if time.is_a?(String)
        time = time.split.inject { |count, unit| count.to_i.send(unit) }
      end

      self.where("created_at < '#{time.ago.to_s(:db)}'").destroy_all
    end

    private

    def add_sequence_plain_text_error
    end

    #
    # Filter input sequences by type (AA or NA) and place each in it's
    # appropriate attribute.
    #
    def filter_input_sequences
      # Ensure the sequences are in plain text.
      begin
        ActiveSupport::Multibyte::Unicode.u_unpack(self.sequence)
      rescue NoMethodError, ActiveSupport::Multibyte::EncodingError => e
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
        (self.blastp_job && self.blastp_job.queue)
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

  end
end
