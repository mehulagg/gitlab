# frozen_string_literal: true

module Geo
  module BlobReplicatorStrategy
    extend ActiveSupport::Concern

    include ::Geo::VerifiableReplicator
    include Gitlab::Geo::LogHelpers

    included do
      event :created
      event :deleted
    end

    def handle_after_create_commit
      return false unless Gitlab::Geo.primary?
      return unless self.class.enabled?

      publish(:created, **created_params)

      after_verifiable_update
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_created(**params)
      return unless in_replicables_for_current_secondary?

      download
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_deleted(**params)
      replicate_destroy(params)
    end

    # Return the carrierwave uploader instance scoped to current model
    #
    # @abstract
    # @return [Carrierwave::Uploader]
    def carrierwave_uploader
      raise NotImplementedError
    end

    # Return the absolute path to locally stored package file
    #
    # @return [String] File path
    def blob_path
      carrierwave_uploader.path
    end

    def replicate_destroy(event_data)
      ::Geo::FileRegistryRemovalService.new(
        replicable_name,
        model_record_id,
        event_data[:blob_path]
      ).execute
    end

    private

    def download
      ::Geo::BlobDownloadService.new(replicator: self).execute
    end

    def deleted_params
      { model_record_id: model_record.id, blob_path: blob_path }
    end
  end
end
