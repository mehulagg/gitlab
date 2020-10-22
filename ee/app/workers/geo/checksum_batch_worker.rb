# frozen_string_literal: true

module Geo
  class ChecksumBatchWorker
    include ApplicationWorker
    include GeoQueue
    include LimitedCapacity::Worker
    include ::Gitlab::Geo::LogHelpers

    idempotent!
    loggable_arguments 0

    def perform_work(replicator_class)
      replicator_class.batch_calculate_checksum
    end

    # This method helps answer the questions:
    #
    # - Should this worker be reenqueued after it finishes its batch?
    # - How many workers should the parent cron worker start?
    #
    def remaining_work_count(replicator_class)
      @remaining_work_count ||= replicator_class
        .remaining_checksum_batch_count(max_batch_count: remaining_capacity)
    end

    # Half capacity since Project and Wiki Repository verification is handled elsewhere
    def max_running_jobs
      [1, Gitlab::Geo.current_node.verification_max_capacity / 2].max
    end
  end
end
