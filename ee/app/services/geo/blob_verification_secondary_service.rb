# frozen_string_literal: true

module Geo
  class BlobVerificationSecondaryService
    include Delay
    include Gitlab::Geo::LogHelpers

    def initialize(replicator)
      @replicator = replicator
      @registry = replicator.registry
    end

    def execute
      return unless Gitlab::Geo.geo_database_configured?
      return unless Gitlab::Geo.secondary?
      return unless should_verify_checksum?

      verify_checksum
    end

    private

    attr_reader :replicator, :registry

    delegate :model_record, :primary_checksum, :secondary_checksum, to: :replicator

    def should_verify_checksum?
      return false unless registry.synced?
      return false unless primary_checksum.present?

      mismatch?(secondary_checksum)
    end

    def mismatch?(checksum)
      primary_checksum != checksum
    end

    def verify_checksum
      checksum = model_record.calculate_checksum!

      if mismatch?(checksum)
        update_registry!(mismatch: checksum, failure: 'checksum mismatch')
      else
        update_registry!(checksum: checksum)
      end
    rescue => e
      update_registry!(failure: 'Error calculating checksum', exception: e)
    end

    def update_registry!(checksum: nil, mismatch: nil, failure: nil, exception: nil)
      reverify, verification_retry_count =
        if mismatch || failure.present?
          log_error(failure, exception)
          [true, registry.verification_retry_count.to_i + 1]
        else
          [false, nil]
        end

      resync_retry_at, resync_retry_count =
        if reverify
          [*calculate_next_retry_attempt]
        end

      registry.update!(
        verification_checksum: checksum,
        verification_checksum_mismatched: mismatch,
        checksum_mismatch: mismatch.present?,
        verified_at: Time.current,
        verification_failure: failure,
        verification_retry_count: verification_retry_count,
        retry_at: resync_retry_at,
        retry_count: resync_retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = registry.retry_count.to_i + 1
      [next_retry_time(retry_count), retry_count]
    end
  end
end
