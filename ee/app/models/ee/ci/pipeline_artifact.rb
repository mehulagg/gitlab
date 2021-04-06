# frozen_string_literal: true

module EE
  module Ci
    module PipelineArtifact
      extend ActiveSupport::Concern

      prepended do
        include ::Gitlab::Geo::ReplicableModel
        include ::Gitlab::Geo::VerificationState

        with_replicator ::Geo::PipelineArtifactReplicator
      end
    end
  end
end
