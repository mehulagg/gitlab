# frozen_string_literal: true

module Geo
  module VerifiableReplicator
    extend ActiveSupport::Concern

    include Delay

    class_methods do
      def checksummed
        model.available_replicables.checksummed
      end

      def checksummed_count
        model.available_replicables.checksummed.count
      end

      def checksum_failed_count
        model.verification_failed.count
      end
    end

    def after_verifiable_update
      schedule_checksum_calculation if needs_checksum?
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

    def needs_checksum?
      return true unless model_record.respond_to?(:needs_checksum?)

      model_record.needs_checksum?
    end

    # Checksum value from the main database
    #
    # @abstract
    def primary_checksum
      model_record.verification_checksum
    end

    def secondary_checksum
      registry.verification_checksum
    end

    private

    # Update checksum on Geo primary database
    #
    # @param [String] checksum value generated by the checksum routine
    # @param [String] failure (optional) stacktrace from failed execution
    def update_verification_state!(checksum: nil, failure: nil)
      retry_at, retry_count = calculate_next_retry_attempt if failure.present?

      model_record.update!(
        verification_checksum: checksum,
        verified_at: Time.current,
        verification_failure: failure,
        verification_retry_at: retry_at,
        verification_retry_count: retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = model_record.verification_retry_count.to_i + 1
      [next_retry_time(retry_count), retry_count]
    end

    def schedule_checksum_calculation
      raise NotImplementedError
    end
  end
end
