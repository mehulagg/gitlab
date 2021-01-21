# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IngressModsecurityCounterMetricsWorker, :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  subject(:worker) { described_class.new }

  let(:ingress_usage_service) { instance_double('EE::Security::IngressModsecurityUsageService', execute: usage_statistics) }
  let(:usage_statistics) do
    {
      statistics_unavailable: 2,
      packets_processed: 10_200,
      packets_anomalous: 2_500
    }
  end

  before do
    allow(EE::Security::IngressModsecurityUsageService).to receive(:new) { ingress_usage_service }
  end

  describe '#perform' do
    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(usage_ingress_modsecurity_counter: false)
      end

      it 'does not update the usae counter' do
        worker.perform
        expect(Gitlab::UsageDataCounters::IngressModsecurityCounter.totals).to eq(
          ingress_modsecurity_packets_anomalous: 0,
          ingress_modsecurity_packets_processed: 0,
          ingress_modsecurity_statistics_unavailable: 0
        )
      end
    end

    context 'with exclusive lease' do
      let(:lease_key) { "#{described_class.name.underscore}" }

      before do
        stub_exclusive_lease_taken(lease_key)
      end

      it 'does not allow to add counters concurrently' do
        expect(Gitlab::UsageDataCounters::IngressModsecurityCounter).not_to receive(:add)

        worker.perform
      end
    end

    it 'updates usage counter' do
      worker.perform
      expect(Gitlab::UsageDataCounters::IngressModsecurityCounter.totals).to eq(
        ingress_modsecurity_packets_anomalous: 2_500,
        ingress_modsecurity_packets_processed: 10_200,
        ingress_modsecurity_statistics_unavailable: 2
      )
    end
  end
end
