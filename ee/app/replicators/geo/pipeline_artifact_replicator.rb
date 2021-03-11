# frozen_string_literal: true

module Geo
  class PipelineArtifactReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def self.model
      ::Ci::PipelineArtifact
    end

    def self.replication_enabled_by_default?
      false
    end

    def carrierwave_uploader
      model_record.file
    end
  end
end
