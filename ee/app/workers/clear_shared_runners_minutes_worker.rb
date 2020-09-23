# frozen_string_literal: true

class ClearSharedRunnersMinutesWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  # all queries are scoped across multiple namespaces
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext
  feature_category :continuous_integration

  LEASE_TIMEOUT = 3600
  BATCH_SIZE = 100_000

  def perform
    if Feature.enabled?(:ci_parallel_minutes_reset, default_enabled: true)
      start_id = Namespace.minimum(:id)
      last_id = Namespace.maximum(:id)

      (start_id..last_id).step(BATCH_SIZE) do |batch_start_id|
        batch_end_id = batch_start_id + BATCH_SIZE - 1
        Ci::BatchResetMinutesWorker.perform_async(batch_start_id, batch_end_id)
      end
    else
      return unless try_obtain_lease

      Ci::Minutes::BatchResetService.new.execute!
    end
  end

  private

  def try_obtain_lease
    Gitlab::ExclusiveLease.new('gitlab_clear_shared_runners_minutes_worker',
      timeout: LEASE_TIMEOUT).try_obtain
  end
end
