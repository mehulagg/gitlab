# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class CountDistinct
        def initialize(events:, start_date:, end_date:, context: {})
          @redis_keys = Gitlab::RedisTracker::Event::Key.new.redis_count_distinct_keys(events: events, start_date: start_date, end_date: end_date, context: context)
        end

        def fetch
          Gitlab::Redis::HLL.count(keys: @redis_keys)
        end
      end
    end
  end
end
