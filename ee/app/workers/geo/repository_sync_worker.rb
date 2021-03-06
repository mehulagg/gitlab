# frozen_string_literal: true

module Geo
  class RepositorySyncWorker < Geo::Scheduler::Secondary::PerShardSchedulerWorker # rubocop:disable Scalability/IdempotentWorker
    tags :exclude_from_gitlab_com

    def schedule_job(shard_name)
      Geo::RepositoryShardSyncWorker.perform_async(shard_name)
      Geo::DesignRepositoryShardSyncWorker.perform_async(shard_name)
    end
  end
end
