module Quorum
  class GmapJob < ActiveRecord::Base

    before_validation :check_gmap_dbs, :if => :queue

    before_save :set_optional_params, :set_gmap_dbs

    belongs_to :job
    has_many :gmap_job_reports,
      :dependent   => :destroy,
      :foreign_key => :gmap_job_id,
      :primary_key => :job_id

    attr_accessible :intron_len, :total_len, :chimera_margin,
      :prune_level, :cross_species, :splicing, :gmap_dbs,
      :queue

    validates_numericality_of :intron_len,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :total_len,
      :only_integer => true,
      :allow_blank  => true
    validates_numericality_of :chimera_margin,
      :only_integer => true,
      :allow_blank  => true
    validates_presence_of :gmap_dbs, :if => :queue

    private

    def check_gmap_dbs
      if self.gmap_dbs.present?
        self.gmap_dbs = self.gmap_dbs.delete_if { |g| g.empty? }
      end
    end

    def set_gmap_dbs
      if self.gmap_dbs.present?
        self.gmap_dbs = self.gmap_dbs.join(';')
      end
    end

    def set_optional_params
      if self.splicing
        self.intron_len ||= Quorum.gmap_max_internal_intron_len
        self.total_len  ||= Quorum.gmap_max_total_intron_len
      else
        self.intron_len = nil
        self.total_len  = nil
      end
      self.chimera_margin ||= 40
    end

  end
end
