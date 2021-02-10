# frozen_string_literal: true

module Geo
  class ReverificationBatchWorker
    include ApplicationWorker
    include GeoQueue
    include LimitedCapacity::Worker
    include ::Gitlab::Geo::LogHelpers

    MAX_RUNNING_JOBS = 1

    idempotent!
    loggable_arguments 0

    def perform_work(replicable_name)
      replicator_class = replicator_class_for(replicable_name)

      replicator_class.reverify_batch!
    end

    def remaining_work_count(replicable_name)
      replicator_class = replicator_class_for(replicable_name)

      @remaining_work_count ||= replicator_class
        .remaining_reverification_batch_count(max_batch_count: remaining_capacity)
    end

    def max_running_jobs
      MAX_RUNNING_JOBS
    end

    def replicator_class_for(replicable_name)
      @replicator_class ||= ::Gitlab::Geo::Replicator.for_replicable_name(replicable_name)
    end
  end
end
