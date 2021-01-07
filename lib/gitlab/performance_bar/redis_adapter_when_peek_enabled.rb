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

      # schedules a job which parses peek profile data and adds them
      # to a structured log
      def enqueue_stats_job(request_id)
        return unless gather_stats?

        @client.sadd(GitlabPerformanceBarStatsWorker::STATS_KEY, request_id) # rubocop:disable Gitlab/ModuleWithInstanceVariables

        return unless uuid = Gitlab::ExclusiveLease.new(
          GitlabPerformanceBarStatsWorker::LEASE_KEY,
          timeout: GitlabPerformanceBarStatsWorker::LEASE_TIMEOUT
        ).try_obtain

        # stats key should be periodically processed and deleted by
        # GitlabPerformanceBarStatsWorker but if it doesn't happen for
        # some reason, we set expiration for the stats key to avoid
        # keeping millions of request ids which would be already expired
        # anyway
        @client.expire(
          GitlabPerformanceBarStatsWorker::STATS_KEY,
          GitlabPerformanceBarStatsWorker::STATS_KEY_EXPIRE
        )

        GitlabPerformanceBarStatsWorker.perform_in(
          GitlabPerformanceBarStatsWorker::WORKER_DELAY,
          uuid
        )
      end

      def gather_stats?
        return unless Feature.enabled?(:performance_bar_stats)

        Gitlab.com? || Gitlab.staging? || !Rails.env.production?
      end
    end
  end
end
