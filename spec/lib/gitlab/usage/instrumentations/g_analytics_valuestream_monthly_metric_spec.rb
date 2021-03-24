# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::GAnalyticsValuestreamMonthlyMetric, :clean_gitlab_redis_shared_state do
  let_it_be(:board) { create(:board) }

  it 'has correct value' do
    Gitlab::UsageDataCounters::HLLRedisCounter.track_event(:g_analytics_valuestream, values: 1, time: 1.week.ago)

    expect(subject.value).to eq(1)
  end
end
