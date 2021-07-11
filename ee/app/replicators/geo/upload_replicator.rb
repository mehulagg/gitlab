# frozen_string_literal: true

module Geo
  class UploadReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy
    extend ::Gitlab::Utils::Override

    def self.model
      ::Upload
    end

    def carrierwave_uploader
      model_record.file
    end

    def self.replication_enabled_by_default?
      false
    end

    override :verification_feature_flag_enabled?
    def self.verification_feature_flag_enabled?
      true
    end

  end
end
