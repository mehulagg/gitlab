# frozen_string_literal: true

module Geo
  module VerifiableReplicator
    extend ActiveSupport::Concern

    include Delay

    class_methods do
      # If replication is disabled, then so is verification.
      def verification_enabled?
        enabled? && verification_feature_flag_enabled?
      end

      # Overridden by PackageFileReplicator with its own feature flag so we can
      # release verification for PackageFileReplicator alone, at first.
      # This feature flag name is not dynamic like the replication feature flag,
      # because Geo is proliferating too many permanent feature flags, and if
      # there is a serious bug with verification that needs to be shut off
      # immediately, then the replication feature flag can be disabled until it
      # is fixed. This feature flag is intended to be removed after it is
      # defaulted on.
      # See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/46998 for more
      def verification_feature_flag_enabled?
        Feature.enabled?(:geo_framework_verification)
      end

      def checksummed
        model.available_replicables.verification_success
      end

      def checksummed_count
        # When verification is disabled, this returns nil.
        # Bonus: This causes the progress bar to be hidden.
        return unless verification_enabled?

        model.available_replicables.verification_success.count
      end

      def checksum_failed_count
        # When verification is disabled, this returns nil.
        # Bonus: This causes the progress bar to be hidden.
        return unless verification_enabled?

        model.available_replicables.verification_failed.count
      end
    end

    def after_verifiable_update
      schedule_checksum_calculation if needs_checksum?
    end

    def verify
      checksum = model_record.calculate_checksum!
      model_record.update_verification_state!(checksum: checksum)
    rescue => e
      log_error('Error calculating the checksum', e)
      model_record.update_verification_state!(failure: e.message)
    end

    # Check if given checksum matches known one
    #
    # @param [String] checksum
    # @return [Boolean] whether checksum matches
    def matches_checksum?(checksum)
      model_record.verification_checksum == checksum
    end

    def needs_checksum?
      return false unless self.class.verification_enabled?
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

    def schedule_checksum_calculation
      raise NotImplementedError
    end
  end
end
