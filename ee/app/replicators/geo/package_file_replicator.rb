# frozen_string_literal: true

module Geo
  class PackageFileReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def self.model
      ::Packages::PackageFile
    end

    # See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/46998 for
    # reasoning about this override.
    def self.verification_feature_flag_enabled?
      Feature.enabled?(:geo_package_file_verification)
    end

    def carrierwave_uploader
      model_record.file
    end
  end
end
