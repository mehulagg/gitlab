# frozen_string_literal: true

module Geo
  class PipelineArtifactRegistry < Geo::BaseRegistry
    include ::Geo::ReplicableRegistry
    include ::Geo::VerifiableRegistry

    MODEL_CLASS = ::Ci::PipelineArtifact
    MODEL_FOREIGN_KEY = :pipeline_artifact_id

    belongs_to :pipeline_artifact, class_name: '::Ci::PipelineArtifact'
  end
end
