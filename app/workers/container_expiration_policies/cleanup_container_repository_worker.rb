# frozen_string_literal: true

module ContainerExpirationPolicies
  class CleanupContainerRepositoryWorker
    include ApplicationWorker
    include LimitedCapacity::Worker
    include Gitlab::Utils::StrongMemoize

    queue_namespace :container_repository
    feature_category :container_registry
    urgency :low
    worker_resource_boundary :unknown
    idempotent!

    LOG_ON_DONE_FIELDS = %i[
      cleanup_status
      cleanup_tags_service_original_size
      cleanup_tags_service_before_truncate_size
      cleanup_tags_service_after_truncate_size
      cleanup_tags_service_before_delete_size
      cleanup_tags_service_deleted_size
    ].freeze

    def perform_work
      return unless throttling_enabled?
      return unless container_repository

      log_extra_metadata_on_done(:container_repository_id, container_repository.id)
      log_extra_metadata_on_done(:project_id, project.id)

      unless allowed_to_run?(container_repository)
        container_repository.cleanup_unscheduled!
        log_extra_metadata_on_done(:cleanup_status, :skipped)
        return
      end

      result = ContainerExpirationPolicies::CleanupService.new(container_repository)
                                                          .execute
      log_on_done(result)
    end

    def remaining_work_count
      cleanup_scheduled_count = ContainerRepository.cleanup_scheduled.count
      cleanup_unfinished_count = ContainerRepository.cleanup_unfinished.count
      total_count = cleanup_scheduled_count + cleanup_unfinished_count

      log_info(
        cleanup_scheduled_count: cleanup_scheduled_count,
        cleanup_unfinished_count: cleanup_unfinished_count,
        cleanup_total_count: total_count
      )

      total_count
    end

    def max_running_jobs
      return 0 unless throttling_enabled?

      ::Gitlab::CurrentSettings.current_application_settings.container_registry_expiration_policies_worker_capacity
    end

    private

    def allowed_to_run?(container_repository)
      return false unless policy&.enabled && policy&.next_run_at

      Time.zone.now + max_cleanup_execution_time.seconds < policy.next_run_at
    end

    def throttling_enabled?
      Feature.enabled?(:container_registry_expiration_policies_throttling)
    end

    def max_cleanup_execution_time
      ::Gitlab::CurrentSettings.current_application_settings.container_registry_delete_tags_service_timeout
    end

    def policy
      project.container_expiration_policy
    end

    def project
      container_repository.project
    end

    def container_repository
      strong_memoize(:container_repository) do
        ContainerRepository.transaction do
          # rubocop: disable CodeReuse/ActiveRecord
          # We need a lock to prevent two workers from picking up the same row
          container_repository = ContainerRepository.waiting_for_cleanup
                                                    .order(:expiration_policy_cleanup_status, :expiration_policy_started_at)
                                                    .limit(1)
                                                    .lock('FOR UPDATE SKIP LOCKED')
                                                    .first
          # rubocop: enable CodeReuse/ActiveRecord
          container_repository&.tap(&:cleanup_ongoing!)
        end
      end
    end

    def log_info(extra_structure)
      logger.info(structured_payload(extra_structure))
    end

    def log_on_done(result)
      LOG_ON_DONE_FIELDS.each do |field|
        value = result.payload[field]

        next if value.nil?

        log_extra_metadata_on_done(field, value)
      end

      before_truncate_size = result.payload[:cleanup_tags_service_before_truncate_size]
      after_truncate_size = result.payload[:cleanup_tags_service_after_truncate_size]
      truncated = before_truncate_size &&
                    after_truncate_size &&
                    before_truncate_size != after_truncate_size
      log_extra_metadata_on_done(:cleanup_tags_service_truncated, !!truncated)
    end
  end
end
