# frozen_string_literal: true

class CleanupContainerRepositoryLimitedCapacityWorker
  include ApplicationWorker
  include LimitedCapacity::Worker
  include Gitlab::Utils::StrongMemoize

  queue_namespace :container_repository
  feature_category :container_registry
  urgency :low
  worker_resource_boundary :unknown
  idempotent!
  loggable_arguments 2

  sidekiq_options queue: 'container_repository:cleanup_container_repository' # rubocop: disable Cop/SidekiqOptionsQueue

  CONTAINER_REPOSITORY_IDS_QUEUE = 'cleanup_container_repository_limited_capacity_worker:container_repository_ids'

  def perform_work
    return unless container_repository

    log_info(container_repository_id: container_repository.id, cleanup_status: :starting)

    result = Projects::ContainerRepository::CleanupTagsService
      .new(project, nil, policy_params.merge(container_expiration_policy: true))
      .execute(container_repository)

    log_info(container_repository_id: container_repository.id, cleanup_status: :done, service_result_status: result[:status], service_result_message: result[:message])

    return if result[:status] == :success

    reenqueue_container_repository_id(container_repository.id)

    log_info(container_repository_id: container_repository.id, cleanup_status: :re_enqueued)
  end

  def remaining_work_count
    work_count = Sidekiq.redis { |redis| redis.llen(CONTAINER_REPOSITORY_IDS_QUEUE) }

    log_info(work_count: work_count)

    work_count
  end

  def max_running_jobs
    ::Gitlab::CurrentSettings.current_application_settings.container_registry_expiration_policies_worker_capacity
  end

  private

  def policy_params
    return {} unless project.container_expiration_policy

    project.container_expiration_policy.policy_params
  end

  def project
    container_repository&.project
  end

  def container_repository
    strong_memoize(:container_repository) do
      ContainerRepository.find_by_id(container_repository_id)
    end
  end

  def container_repository_id
    Sidekiq.redis { |redis| redis.lpop(CONTAINER_REPOSITORY_IDS_QUEUE) }
  end

  def reenqueue_container_repository_id(id)
    Sidekiq.redis do |redis|
      # TODO instead of always rpushing we could check the id existence in the
      # list with lpos. Unfortunately, lpos is not (yet) supported by the ruby
      # redis client
      redis.rpush(CONTAINER_REPOSITORY_IDS_QUEUE, id)
    end
  end

  def log_info(extra_structure)
    logger.info(structured_payload(extra_structure))
  end
end
