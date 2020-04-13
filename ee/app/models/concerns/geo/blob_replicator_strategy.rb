# frozen_string_literal: true

module Geo
  module BlobReplicatorStrategy
    extend ActiveSupport::Concern

    include Delay
    include Gitlab::Geo::LogHelpers

    included do
      event :created
    end

    class_methods do
    end

    def handle_after_create_commit
      publish(:created, **created_params)

      return unless Feature.enabled?(:geo_self_service_framework)

      schedule_checksum_calculation if needs_checksum?
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_created_event
      download
    end

    # Return the carrierwave uploader instance scoped to current model
    #
    # @abstract
    # @return [Carrierwave::Uploader]
    def carrierwave_uploader
      raise NotImplementedError
    end

    def calculate_checksum!
      checksum = model_record.calculate_checksum!
      update_verification_state!(checksum: checksum)
    rescue => e
      log_error('Error calculating the checksum', e)
      update_verification_state!(failure: e.message)
    end

    # Check if given checksum matches known one
    #
    # @param [String] checksum
    # @return [Boolean] whether checksum matches
    def matches_checksum?(checksum)
      model_record.verification_checksum == checksum
    end

    private

    def update_verification_state!(checksum: nil, failure: nil)
      retry_at, retry_count = calculate_next_retry_attempt if failure.present?

      model_record.update!(
        verification_checksum: checksum,
        verified_at: Time.now,
        verification_failure: failure,
        verification_retry_at: retry_at,
        verification_retry_count: retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = model_record.verification_retry_count.to_i + 1
      [next_retry_time(retry_count), retry_count]
    end

    def download
      ::Geo::BlobDownloadService.new(replicator: self).execute
    end

    def schedule_checksum_calculation
      Geo::BlobVerificationPrimaryWorker.perform_async(replicable_name, model_record.id)
    end

    def created_params
      { model_record_id: model_record.id }
    end

    def needs_checksum?
      return true unless model_record.respond_to?(:needs_checksum?)

      model_record.needs_checksum?
    end
  end
end
