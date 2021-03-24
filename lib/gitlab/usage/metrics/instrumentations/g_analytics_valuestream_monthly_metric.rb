# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class GAnalyticsValuestreamMonthlyMetric < BaseMetric
          def value
            redis_usage_data { Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(event_names: :g_analytics_valuestream, start_date: 4.weeks.ago.to_date, end_date: Date.current ) }
          end
        end
      end
    end
  end
end
