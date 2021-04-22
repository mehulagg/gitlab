# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class CountUsersVisitingAnalyticsValuestreamMetric < RedisHLLMetric
          event_names :g_analytics_valuestream
        end
      end
    end
  end
end
