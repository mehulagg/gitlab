# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class IncrementDistinct
        DEFAULT_WEEKLY_KEY_EXPIRY_LENGTH = 6.weeks

        def initialize(event:, values:, context: {}, date: Date.current)
          @values = values
          @definition = Gitlab::RedisTracker::Event::Definition.new(event: event)
          @redis_key = Gitlab::RedisTracker::Event::Key.new.redis_increment_distinct_key(event, date, context)
        end

        def trigger
          return unless @definition.enabled_for_tracking?

          Gitlab::Redis::HLL.add(key: @redis_key, value: @values, expiry: DEFAULT_WEEKLY_KEY_EXPIRY_LENGTH)
        end
      end
    end
  end
end
