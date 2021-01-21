# frozen_string_literal: true

module Geo
  module VerifiableReplicator
    extend ActiveSupport::Concern

    include Delay

    DEFAULT_VERIFICATION_BATCH_SIZE = 10

    class_methods do
      extend Gitlab::Utils::Override

      delegate :verification_pending_batch, :verification_failed_batch, :needs_verification_count, :fail_verification_timeouts, to: :verification_query_class

      # If replication is disabled, then so is verification.
      override :verification_enabled?
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

      # Called every minute by VerificationCronWorker
      def trigger_background_verification
        return false unless verification_enabled?

        ::Geo::VerificationBatchWorker.perform_with_capacity(replicable_name)

        ::Geo::VerificationTimeoutWorker.perform_async(replicable_name)
      end

      # Called by VerificationBatchWorker.
      #
      # - Gets next batch of records that need to be verified
      # - Verifies them
      #
      def verify_batch
        self.replicator_batch_to_verify.each(&:verify)
      end

      # Called by VerificationBatchWorker.
      #
      # - Asks the DB how many things still need to be verified (with a limit)
      # - Converts that to a number of batches
      #
      # @return [Integer] number of batches of verification work remaining, up to the given maximum
      def remaining_verification_batch_count(max_batch_count:)
        needs_verification_count(limit: max_batch_count * verification_batch_size)
          .fdiv(verification_batch_size)
          .ceil
      end

      # @return [Array<Gitlab::Geo::Replicator>] batch of replicators which need to be verified
      def replicator_batch_to_verify
        model_record_id_batch_to_verify.map do |id|
          self.new(model_record_id: id)
        end
      end

      # @return [Array<Integer>] list of IDs for this replicator's model which need to be verified
      def model_record_id_batch_to_verify
        ids = verification_pending_batch(batch_size: verification_batch_size)

        remaining_batch_size = verification_batch_size - ids.size

        if remaining_batch_size > 0
          ids += verification_failed_batch(batch_size: remaining_batch_size)
        end

        ids
      end

      # If primary, query the model table.
      # If secondary, query the registry table.
      def verification_query_class
        Gitlab::Geo.secondary? ? registry_class : model
      end

      # @return [Integer] number of records to verify per batch job
      def verification_batch_size
        DEFAULT_VERIFICATION_BATCH_SIZE
      end

      def checksummed_count
        # When verification is disabled, this returns nil.
        # Bonus: This causes the progress bar to be hidden.
        return unless verification_enabled?

        model.available_replicables.verification_succeeded.count
      end

      def checksum_failed_count
        # When verification is disabled, this returns nil.
        # Bonus: This causes the progress bar to be hidden.
        return unless verification_enabled?

        model.available_replicables.verification_failed.count
      end
    end

    def after_verifiable_update
      verify_async if needs_checksum?
    end

    def verify_async
      # Marking started prevents backfill (VerificationBatchWorker) from picking
      # this up too.
      # Also, if another verification job is running, this will make that job
      # set state to pending after it finishes, since the calculated checksum
      # is already invalidated.
      model_record.verification_started!

      Geo::VerificationWorker.perform_async(replicable_name, model_record.id)
    end

    # Calculates checksum and asks the model/registry to manage verification
    # state.
    def verify
      model_record.track_checksum_attempt! do
        model_record.calculate_checksum
      end
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
  end
end
