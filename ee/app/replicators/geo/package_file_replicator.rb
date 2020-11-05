# frozen_string_literal: true

module Geo
  class PackageFileReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def self.model
      ::Packages::PackageFile
    end

    def self.verification_enabled?
      # If replication is disabled, then so is verification.
      enabled? && Feature.enabled?(:geo_package_file_verification)
    end

    def carrierwave_uploader
      model_record.file
    end
  end
end
