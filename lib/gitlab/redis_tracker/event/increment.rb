# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class Increment
        INCREMENT_BY = 1

        def initialize(event:, by: INCREMENT_BY)
          @event = event
          @by = by
          @definition = Gitlab::RedisTracker::Event::Definition.new(event: event)
          @redis_key = Gitlab::RedisTracker::Event::Key.new.redis_increment_key(@event)
        end

        def trigger
          return unless @definition.feature_enabled?

          Gitlab::Redis::SharedState.with { |redis| redis.incrby(@redis_key, @by) }
        end
      end
    end
  end
end
