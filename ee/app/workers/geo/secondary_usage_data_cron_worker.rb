# frozen_string_literal: true

module Geo
  class SecondaryUsageDataCronWorker # rubocop:disable Scalability/IdempotentWorker
    LEASE_TIMEOUT = 24.hours.freeze

    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext
    include ::Gitlab::Geo::LogHelpers
    include ExclusiveLeaseGuard

    feature_category :geo_replication

    def perform
      return unless Gitlab::Geo.secondary?
      return unless Feature.enabled?(:geo_secondary_usage_data_collection)

      try_obtain_lease do
        SecondaryUsageData.update_metrics!
      end
    end

    private

    def lease_timeout
      LEASE_TIMEOUT
    end

    def lease_release?
      false
    end
  end
end
