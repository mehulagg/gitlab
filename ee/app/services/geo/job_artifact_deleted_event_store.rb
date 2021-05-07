# frozen_string_literal: true

module Geo
  class JobArtifactDeletedEventStore < EventStore
    extend ::Gitlab::Utils::Override

    self.event_type = :job_artifact_deleted_event

    attr_reader :job_artifact

    def self.bulk_create(artifacts)
      return unless can_create_event?

      events = artifacts
        .map { |artifact| new(artifact).build_valid_event }
        .compact
      return if events.empty?

      Geo::EventLog.transaction do
        ids = JobArtifactDeletedEvent.bulk_insert!(events, validate: false, returns: :ids)
        ids.map! { |id| { "#{event_type}_id" => id, created_at: Time.current } }
        Geo::EventLog.insert_all!(ids)
      end
    end

    def initialize(job_artifact)
      @job_artifact = job_artifact
    end

    def build_valid_event
      event = build_event
      event.validate!
      event

    rescue ActiveRecord::RecordInvalid, NoMethodError => e
      log_error("#{self.class.event_type.to_s.humanize} could not be created", e)
      # This return value is used in the bulk_insert method call
      nil
    end

    private

    def build_event
      Geo::JobArtifactDeletedEvent.new(
        job_artifact: job_artifact,
        file_path: relative_file_path
      )
    end

    def relative_file_path
      job_artifact.file.relative_path if job_artifact.file.present?
    end

    def project
      job_artifact.project
    end

    # This is called by LogHelpers to build json log with context info
    #
    # @see ::Gitlab::Geo::LogHelpers
    def extra_log_data
      {
        job_artifact_id: job_artifact.id,
        file_path: job_artifact.file.path
      }.compact
    end
  end
end
