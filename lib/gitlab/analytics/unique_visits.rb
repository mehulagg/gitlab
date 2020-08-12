# frozen_string_literal: true

module Gitlab
  module Analytics
    class UniqueVisits < UsageDataCounters::HLLRedisCounter
      KNOWN_EVENTS = Set[
        'g_analytics_contribution',
        'g_analytics_insights',
        'g_analytics_issues',
        'g_analytics_productivity',
        'g_analytics_valuestream',
        'p_analytics_pipelines',
        'p_analytics_code_reviews',
        'p_analytics_valuestream',
        'p_analytics_insights',
        'p_analytics_issues',
        'p_analytics_repo',
        'i_analytics_cohorts',
        'i_analytics_dev_ops_score'
      ]

      KEY_EXPIRY_LENGTH = 12.weeks
      REDIS_SLOT = 'analytics'.freeze

      def track_visit(visitor_id, target_id, time = Time.zone.now)
        track_event(visitor_id, target_id, time)
      end

      # Returns number of unique visitors for given targets in given time frame
      #
      # @param [String, Array[<String>]] targets ids of targets to count visits on
      # @param [ActiveSupport::TimeWithZone] start_week start of time frame
      # @param [Integer] weeks time frame length in weeks
      # @return [Integer] number of unique visitors
      def unique_visits_for(targets:, start_week: 7.days.ago, weeks: 1)
        unique_events(events: targets, start_week: start_week, weeks: weeks)
      end
    end
  end
end
