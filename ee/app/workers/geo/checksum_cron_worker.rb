# frozen_string_literal: true

module Geo
  # Calls enqueue_checksum_batch_worker on every enabled replicator class, every
  # minute.
  #
  class ChecksumCronWorker
    include ApplicationWorker
    include ::Gitlab::Geo::LogHelpers

    # This worker does not perform work scoped to a context
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    idempotent!

    feature_category :geo_replication

    def perform
      Gitlab::Geo.enabled_replicator_classes.each do |replicator_class|
        replicator_class.enqueue_checksum_batch_worker
      end
    end
  end
end
