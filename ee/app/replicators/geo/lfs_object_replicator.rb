# frozen_string_literal: true

module Geo
  class LfsObjectReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy
    extend ::Gitlab::Utils::Override

    def carrierwave_uploader
      model_record.file
    end

    def self.model
      ::LfsObject
    end

    override :verification_feature_flag_enabled?
    def self.verification_feature_flag_enabled?
      Feature.enabled?(:geo_lfs_object_verification, default_enabled: :yaml)
    end
  end
end
