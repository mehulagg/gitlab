# frozen_string_literal: true

module Geo
  # Fail sync for records which started syncing a long time ago
  class SyncTimeoutCronWorker
    include ApplicationWorker
    include GeoQueue
    include ::Gitlab::Geo::LogHelpers

    # This worker does not perform work scoped to a context
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    idempotent!
    sidekiq_options retry: false, dead: false

    def perform
      Gitlab::Geo.enabled_replicator_classes.each do |replicator_class|
        replicator_class.fail_sync_timeouts
      end
    end
  end
end
