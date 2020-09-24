# frozen_string_literal: true

class Geo::JobArtifactRegistry < Geo::BaseRegistry
  include Geo::Syncable

  MODEL_CLASS = ::Ci::JobArtifact
  MODEL_FOREIGN_KEY = :artifact_id

  # When false, RegistryConsistencyService will frequently check the end of the
  # table to quickly handle new replicables.
  def self.has_create_events?
    false
  end

  # TODO: remove once `success` column has a default value set
  # https://gitlab.com/gitlab-org/gitlab/-/issues/214407
  def self.insert_for_model_ids(artifact_ids)
    records = artifact_ids.map do |artifact_id|
      new(artifact_id: artifact_id, success: false, created_at: Time.zone.now)
    end

    bulk_insert!(records, returns: :ids)
  end

  def self.delete_for_model_ids(artifact_ids)
    artifact_ids.map do |artifact_id|
      delete_worker_class.perform_async(:job_artifact, artifact_id)
    end
  end
end
