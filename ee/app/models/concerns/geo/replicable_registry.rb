# frozen_string_literal: true

module Geo::ReplicableRegistry
  extend ActiveSupport::Concern

  STATE_VALUES = {
    pending: 0,
    started: 1,
    synced: 2,
    failed: 3
  }.freeze

  class_methods do
    def state_value(state_string)
      STATE_VALUES[state_string]
    end

    def for_model_record_id(id)
      find_or_initialize_by(self::MODEL_FOREIGN_KEY => id)
    end

    def declarative_policy_class
      'Geo::RegistryPolicy'
    end

    def registry_consistency_worker_enabled?
      replicator_class.enabled?
    end
  end

  def replicator_class
    Gitlab::Geo::Replicator.for_class_name(self)
  end

  included do
    include ::Delay
    include ::Gitlab::Geo::VerificationState
    extend ::Gitlab::Utils::Override

    scope :failed, -> { with_state(:failed) }
    scope :needs_sync_again, -> { failed.retry_due }
    scope :never_attempted_sync, -> { pending.where(last_synced_at: nil) }
    scope :ordered, -> { order(:id) }
    scope :pending, -> { with_state(:pending) }
    scope :retry_due, -> { where(arel_table[:retry_at].eq(nil).or(arel_table[:retry_at].lt(Time.current))) }
    scope :synced, -> { with_state(:synced) }

    state_machine :state, initial: :pending do
      state :pending, value: STATE_VALUES[:pending]
      state :started, value: STATE_VALUES[:started]
      state :synced, value: STATE_VALUES[:synced]
      state :failed, value: STATE_VALUES[:failed]

      before_transition any => :started do |registry, _|
        registry.last_synced_at = Time.current
      end

      before_transition any => :pending do |registry, _|
        registry.retry_at = 0
        registry.retry_count = 0
      end

      before_transition any => :failed do |registry, _|
        registry.retry_count += 1
        registry.retry_at = registry.next_retry_time(registry.retry_count)
      end

      before_transition any => :synced do |registry, _|
        registry.retry_count = 0
        registry.last_sync_failure = nil
        registry.retry_at = nil
      end

      event :start do
        transition [:pending, :synced, :failed] => :started
      end

      event :synced do
        transition [:started] => :synced
      end

      event :failed do
        transition [:started] => :failed
      end

      event :resync do
        transition [:synced, :failed] => :pending
      end
    end

    # Override state machine failed! event method to record a failure message at
    # the same time.
    #
    # @param [String] message error information
    # @param [StandardError] error exception
    def failed!(message, error = nil)
      self.last_sync_failure = message
      self.last_sync_failure += ": #{error.message}" if error.respond_to?(:message)

      super()
    end

    override :clear_verification_failure_fields
    def clear_verification_failure_fields
      super

      self.verification_checksum_mismatch = nil
      self.checksum_mismatch = false
    end

    override :track_checksum_result!
    def track_checksum_result!(checksum, calculation_started_at)
      unless matches_checksum?(checksum)
        return verification_failed_due_to_mismatch!(checksum, calculation_started_at)
      end

      verification_succeeded_with_checksum!(checksum, calculation_started_at)
    end

    # Records a checksum mismatch
    #
    # @param [String] checksum value which does not match the primary checksum
    def verification_failed_due_to_mismatch!(checksum, primary_checksum)
      message = 'Checksum does not match the primary checksum'
      details = { checksum: checksum, primary_checksum: primary_checksum }

      log_info(message, details)

      self.verification_failure = "#{message} #{details}"
      self.verification_checksum = checksum
      self.verification_checksum_mismatch = checksum
      self.checksum_mismatch = true

      self.verification_failed!
    end
  end
end
