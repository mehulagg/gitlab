# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::GAnalyticsValuestreamMonthlyMetric, :clean_gitlab_redis_shared_state do
  before do
    Gitlab::UsageDataCounters::HLLRedisCounter.track_event(:g_analytics_valuestream, values: 1, time: 1.week.ago)
    Gitlab::UsageDataCounters::HLLRedisCounter.track_event(:g_analytics_valuestream, values: 1, time: 2.months.ago)
  end

  it_behaves_like 'a correct instrumented metric value', 1
end
