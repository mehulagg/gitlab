# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Aggregates::Aggregate, :clean_gitlab_redis_shared_state do
  describe '.new' do
    it 'loads aggregated metrics from both sources' do
      expect(Dir).to receive(:[]).with(Gitlab::Usage::Metrics::Aggregates::AGGREGATED_METRICS_PATH).and_return([])
      expect(Dir).to receive(:[]).with(described_class::EE_AGGREGATED_METRICS_PATH).and_return([])

      described_class.new(Time.current.to_i)
    end
  end
end
