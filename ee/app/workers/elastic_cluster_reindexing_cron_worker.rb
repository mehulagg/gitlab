# frozen_string_literal: true

class ElasticClusterReindexingCronWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext
  include Gitlab::ExclusiveLeaseHelpers

  sidekiq_options retry: false

  feature_category :global_search
  urgency :throttled
  idempotent!

  def perform
    in_lock(self.class.name.underscore, ttl: 1.hour, retries: 10, sleep_sec: 1) do
      Elastic::ReindexingTask.drop_old_indices!

      task = Elastic::ReindexingTask.current
      break false unless task

      # support currently running reindexing processes during an upgrade
      if task.subtasks.where.not(elastic_task: nil).any? # rubocop: disable CodeReuse/ActiveRecord
        legacy_service.execute
      else
        service.execute
      end
    end
  end

  private

  def service
    Elastic::ClusterReindexingService.new
  end

  def legacy_service
    Elastic::LegacyReindexingService.new
  end
end
