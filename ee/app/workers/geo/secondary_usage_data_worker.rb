# frozen_string_literal: true

module Geo
  class SecondaryUsageDataWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    # rubocop:disable Scalability/CronWorkerContext
    # This worker does not perform work scoped to a context
    include CronjobQueue
    # rubocop:enable Scalability/CronWorkerContext
    include ::Gitlab::Geo::LogHelpers

    def perform
    end
  end
end
