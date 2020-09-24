# frozen_string_literal: true

module Geo
  class TerraformStateReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def carrierwave_uploader
      model_record.file
    end

    def handle_after_create_commit
      return if model_record.versioning_enabled?

      super
    end

    def handle_after_destroy
      return if model_record.versioning_enabled?

      super
    end

    def self.model
      ::Terraform::State
    end

    def self.replication_enabled_by_default?
      false
    end
  end
end
