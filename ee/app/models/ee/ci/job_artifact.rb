# frozen_string_literal: true

module EE
  # CI::JobArtifact EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Ci::JobArtifact` model
  module Ci::JobArtifact
    extend ActiveSupport::Concern

    prepended do
      after_destroy :log_geo_deleted_event

      SECURITY_REPORT_FILE_TYPES = %w[sast dependency_scanning container_scanning dast].freeze

      scope :not_expired, -> { where('expire_at IS NULL OR expire_at > ?', Time.current) }
      scope :geo_syncable, -> { with_files_stored_locally.not_expired }

      scope :security_reports, -> do
        with_file_types(SECURITY_REPORT_FILE_TYPES)
      end
    end

    def log_geo_deleted_event
      ::Geo::JobArtifactDeletedEventStore.new(self).create!
    end
  end
end
