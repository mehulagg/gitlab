# frozen_string_literal: true

module Geo
  class PipelineArtifactReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy
    extend ::Gitlab::Utils::Override

    def self.model
      ::Ci::PipelineArtifact
    end

    def carrierwave_uploader
      model_record.file
    end

    def self.replication_enabled_by_default?
      false
    end

    override :verification_feature_flag_enabled?
    def self.verification_feature_flag_enabled?
      Feature.enabled?(:geo_pipeline_artifact_replication, default_enabled: :yaml)
    end
  end
end
