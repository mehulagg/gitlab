# frozen_string_literal: true

module Gitlab
  module ProductIntelligence
    module AggregatedMetrics
      module Sources
        class RedisHll
          def self.calculate_events_union(event_names:, start_date:, end_date:)
            Gitlab::UsageDataCounters::HLLRedisCounter
              .calculate_events_union(event_names: event_names, start_date: start_date, end_date: end_date)
          end
        end
      end
    end
  end
end
