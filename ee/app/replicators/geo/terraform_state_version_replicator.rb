# frozen_string_literal: true

module Geo
  class TerraformStateVersionReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def carrierwave_uploader
      model_record.file
    end

    def self.model
      ::Terraform::StateVersion
    end

    # Remove with https://gitlab.com/gitlab-org/gitlab/-/issues/249176
    def self.replication_enabled_by_default?
      false
    end
  end
end
