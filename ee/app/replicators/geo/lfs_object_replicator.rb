# frozen_string_literal: true

module Geo
  class LfsObjectReplicator < Gitlab::Geo::Replicator
    # Include one of the strategies your resource needs
    include ::Geo::BlobReplicatorStrategy

    # Specify the CarrierWave uploader needed by the used strategy
    def carrierwave_uploader
      model_record.file
    end

    # Specify the model this replicator belongs to
    def self.model
      ::LfsObject
    end

    # The feature flag follows the format `geo_#{replicable_name}_replication`,
    # so here it would be `geo_package_file_replication`
    def self.replication_enabled_by_default?
      false
    end
  end
end
