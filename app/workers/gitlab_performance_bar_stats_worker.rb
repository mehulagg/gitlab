# frozen_string_literal: true

class GitlabPerformanceBarStatsWorker
  LEASE_KEY = 'gitlab:performance_bar_stats'
  # LEASE_TIMEOUT = 86400
  LEASE_TIMEOUT = 30
  STATS_KEY = 'performance_bar_stats:pending_request_ids'

  include ApplicationWorker

  #feature_category :collection
  #sidekiq_options retry: 3, dead: false
  #sidekiq_retry_in { |count| (count + 1) * 8.hours.to_i }

  def perform(lease_uuid)
    Gitlab::Redis::SharedState.with do |redis|
      request_ids = fetch_request_ids(redis)
      stats = Gitlab::PerformanceBar::Stats.new

      request_ids.each do |id|
        request = redis.get("peek:requests:#{id}")
        stats.process(request)
      end
    end
  end

  private

  def fetch_request_ids(redis)
    ids = redis.smembers(STATS_KEY)
    redis.del(STATS_KEY)
    Gitlab::ExclusiveLease.cancel(LEASE_KEY, lease_uuid)

    ids
  end
end
