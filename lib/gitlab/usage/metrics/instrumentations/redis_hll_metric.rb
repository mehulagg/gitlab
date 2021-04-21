# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class RedisHLLMetric < BaseMetric
          # Usage example
          #
          # class CountUsersVisitingAnalyticsValuestreamMetric < RedisHLLMetric
          #   event_names :g_analytics_valuestream
          # end
          class << self
            def event_names(events = nil)
              @mentric_events = events
            end

            attr_reader :mentric_events
          end

          def value
            redis_usage_data do
              Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(**redis_hll_time_constraints.merge(event_names: self.class.mentric_events))
            end
          end
        end
      end
    end
  end
end
