# frozen_string_literal: true

module Geo
  module RepositoryVerification
    module Secondary
      class ShardWorker < Geo::Scheduler::Secondary::SchedulerWorker
        include CronjobQueue
        attr_accessor :shard_name

        def perform(shard_name)
          @shard_name = shard_name

          return unless Gitlab::ShardHealthCache.healthy_shard?(shard_name)

          super()
        end

        def lease_key
          @lease_key ||= "#{self.class.name.underscore}:shard:#{shard_name}"
        end

        private

        def skip_cache_key
          "#{self.class.name.underscore}:shard:#{shard_name}:skip"
        end

        def worker_metadata
          { shard: shard_name }
        end

        def max_capacity
          current_node.verification_max_capacity
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def load_pending_resources
          finder.find_registries_to_verify(shard_name: shard_name, batch_size: db_retrieve_batch_size)
                .pluck(:id)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def schedule_job(registry_id)
          job_id = Geo::RepositoryVerification::Secondary::SingleWorker.perform_async(registry_id)

          { id: registry_id, job_id: job_id } if job_id
        end

        def finder
          @finder ||= Geo::ProjectRegistryFinder.new(current_node: current_node)
        end
      end
    end
  end
end
