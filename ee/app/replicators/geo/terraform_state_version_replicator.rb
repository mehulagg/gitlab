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

    def needs_checksum?
      false
    end
  end
end
