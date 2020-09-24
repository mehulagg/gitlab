# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::NetworkPolicyCounter, :clean_gitlab_redis_shared_state do
  describe '.add' do
    it 'increases drops and forwards counters' do
      described_class.add(10, 5)
      expect(described_class.totals).to eq(network_policy_forwards: 10, network_policy_drops: 5)

      described_class.add(2, 1)
      expect(described_class.totals).to eq(network_policy_forwards: 12, network_policy_drops: 6)
    end
  end
end
