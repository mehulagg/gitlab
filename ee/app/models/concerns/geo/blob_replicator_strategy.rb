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
      return false unless Gitlab::Geo.enabled?
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

    private

    def download
      ::Geo::BlobDownloadService.new(replicator: self).execute
    end

    def replicate_destroy(event_data)
      ::Geo::FileRegistryRemovalService.new(
        replicable_name,
        model_record_id,
        event_data[:blob_path]
      ).execute
    end

    def deleted_params
      { model_record_id: model_record.id, blob_path: blob_path }
    end

    def verify_async
      Geo::VerificationWorker.perform_async(replicable_name, model_record.id)
    end
  end
end
