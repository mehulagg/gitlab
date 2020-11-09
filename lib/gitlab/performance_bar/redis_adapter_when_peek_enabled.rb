# frozen_string_literal: true

# Adapted from https://github.com/peek/peek/blob/master/lib/peek/adapters/redis.rb
module Gitlab
  module PerformanceBar
    module RedisAdapterWhenPeekEnabled
      def save(request_id)
        return unless ::Gitlab::PerformanceBar.enabled_for_request?
        return if request_id.blank?

        super

        enqueue_stats_job(request_id)
      end

      def enqueue_stats_job(request_id)
        return unless Gitlab.com? || !Rails.env.production?
        return unless Feature.enabled?(:performance_bar_stats)

        @client.sadd(GitlabPerformanceBarStatsWorker::STATS_KEY, request_id)
        return unless uuid = Gitlab::ExclusiveLease.new(GitlabPerformanceBarStatsWorker::LEASE_KEY, timeout: 10.seconds).try_obtain

        #GitlabPerformanceBarStatsWorker.perform_in(5.minutes, uuid)
        GitlabPerformanceBarStatsWorker.perform_in(1.second, uuid)
      end
    end
  end
end
