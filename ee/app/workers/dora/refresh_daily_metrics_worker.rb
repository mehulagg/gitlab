# frozen_string_literal: true

module Dora
  class RefreshDailyMetricsWorker
    include ApplicationWorker

    idempotent!
    queue_namespace :dora_metrics
    feature_category :dora_metrics

    def perform(environment_id, date)
      Environment.find_by_id(environment_id).try do |environment|
        ::Dora::DailyMetrics.refresh!(environment, Date.parse(date))
      end
    end
  end
end
