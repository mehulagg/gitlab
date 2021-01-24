# frozen_string_literal: true

module Gitlab
  module RedisTracker
    class << self
      # Increment simple Redis event by given value
      def increment(event:, by: 1)
        return unless tracking_enabled?

        Gitlab::RedisTracker::Event::Increment.new(event: event, by: by).trigger
      end

      # Count total events
      def count(event:)
        Gitlab::RedisTracker::Event::CountDistinct.new(event: event).fetch
      end

      # Increment distinct values for given event, date and context using RedisHLL
      def increment_distinct(event:, values:, context: {}, date: Date.current)
        return unless tracking_enabled?

        Gitlab::RedisTracker::Event::IncrementDistinct.new(event: event, values: values, context: context, date: date).trigger
      end

      # Count distinct events union for given period and context
      def count_distinct(events:, start_date:, end_date:, context: {})
        Gitlab::RedisTracker::Event::CountDistinct.new(events: events, start_date: start_date, end_date: end_date, context: context).fetch
      end
      alias_method :count_distinct_union, :count_distinct

      # Count distinct events intersection for given period and context
      def count_distinct_intersection(events:, start_date:, end_date:, context: {})
        Gitlab::RedisTracker::Event::CountDistinctIntersection.new(events: events, start_date: start_date, end_date: end_date, context: context).fetch
      end

      private

      def tracking_enabled?
        Gitlab::CurrentSettings.usage_ping_enabled? && Feature.enabled?(:redis_tracker, type: :ops)
      end
    end
  end
end
