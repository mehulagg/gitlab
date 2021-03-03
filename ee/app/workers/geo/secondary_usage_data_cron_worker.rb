# frozen_string_literal: true

module Geo
  class SecondaryUsageDataCronWorker # rubocop:disable Scalability/IdempotentWorker
    LEASE_KEY = 'secondary_usage_data_worker:ping'
    LEASE_TIMEOUT = 86400

    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext
    include ::Gitlab::Geo::LogHelpers
    include Gitlab::ExclusiveLeaseHelpers

    def perform
      return unless Gitlab::Geo.secondary?
      return unless Feature.enabled?(:geo_secondary_usage_data_collection)

      in_lock(LEASE_KEY, ttl: LEASE_TIMEOUT) do
        # Splay the request over a minute to avoid thundering herd problems.
        sleep(rand(0.0..60.0).round(3))

        SecondaryUsageData.update_metrics!
      end
    end
  end
end
