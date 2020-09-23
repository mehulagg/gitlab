# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::IngressModsecurityCounter, :clean_gitlab_redis_shared_state do
  describe '.add' do
    it 'increases packets_processed and packets_anomalous counters and sets statistics_unavailable counter' do
      described_class.add(3, 10_200, 2_500)
      expect(described_class.totals).to eq(
        ingress_modsecurity_packets_anomalous: 2_500,
        ingress_modsecurity_packets_processed: 10_200,
        ingress_modsecurity_statistics_unavailable: 3
      )

      described_class.add(2, 800, 500)
      expect(described_class.totals).to eq(
        ingress_modsecurity_packets_anomalous: 3_000,
        ingress_modsecurity_packets_processed: 11_000,
        ingress_modsecurity_statistics_unavailable: 2
      )
    end
  end
end
