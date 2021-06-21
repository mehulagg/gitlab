# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NetworkPolicyMetricsWorker, :clean_gitlab_redis_shared_state do
  subject(:worker) { described_class.new }

  let!(:cluster) { create(:cluster, :with_installed_helm, :provided_by_gcp, :project) }
  let!(:cilium_application) { create(:clusters_applications_cilium, :installed, cluster: cluster) }
  let!(:prometheus_application) { create(:clusters_applications_prometheus, :installed, cluster: cluster) }
  let!(:prometheus_integration) { create(:prometheus_integration, project: cluster.projects.first) }

  let(:client) { instance_double('Gitlab::PrometheusClient') }
  let(:query_response) do
    [
      { "metric" => { "verdict" => "FORWARDED" }, "value" => [1582231596.64, "72.43143284984"] },
      { "metric" => { "verdict" => "DROPPED" }, "value" => [1582231596.64, "5.002730665588791"] }
    ]
  end

  before do
    allow(Gitlab::PrometheusClient).to receive(:new) { client }
    stub_request(:get, "https://kubernetes.example.com/api/v1")
      .to_return(status: 200, body: '{"resources":[{"kind":"service","name":"prometheus"}]}')
  end

  describe '#perform' do
    before do
      allow(client).to receive(:query) { query_response }
    end

    it 'updates usage counter' do
      worker.perform

      expect(Gitlab::UsageDataCounters::NetworkPolicyCounter.totals).to eq(network_policy_drops: 10, network_policy_forwards: 144)
    end

    context 'with prometheus application on another cluster' do
      let!(:prometheus_application_without_cilium) { create(:clusters_applications_prometheus, :installed) }

      it 'does not count clusters without cilium' do
        worker.perform

        expect(Gitlab::UsageDataCounters::NetworkPolicyCounter.totals).to eq(network_policy_drops: 10, network_policy_forwards: 144)
      end
    end

    context 'with prometheus integration on another project' do
      let!(:prometheus_integration_without_cilium) { create(:prometheus_integration) }

      it 'does not count projects without cilium' do
        worker.perform

        expect(Gitlab::UsageDataCounters::NetworkPolicyCounter.totals).to eq(network_policy_drops: 10, network_policy_forwards: 144)
      end
    end

    context 'with Prometheus client error' do
      let!(:cluster2) { create(:cluster, :with_installed_helm, :provided_by_gcp, :project) }
      let!(:cilium_application2) { create(:clusters_applications_cilium, :installed, cluster: cluster2) }
      let!(:prometheus_integration2) { create(:prometheus_integration, project: cluster2.projects.first) }

      before do
        idx = 0
        allow(client).to receive(:query) { (idx += 1) == 1 ? raise(Gitlab::PrometheusClient::Error) : query_response }
      end

      it 'adds usage of the rest' do
        worker.perform

        expect(Gitlab::UsageDataCounters::NetworkPolicyCounter.totals).to eq(network_policy_drops: 10, network_policy_forwards: 144)
      end
    end

    context 'with unconfigured adapter' do
      let!(:cluster2) { create(:cluster, :with_installed_helm, :provided_by_gcp, :project) }
      let!(:cilium_application2) { create(:clusters_applications_cilium, :installed, cluster: cluster2) }
      let!(:prometheus_integration2) { create(:prometheus_integration, project: cluster2.projects.first) }

      before do
        prometheus_integration.update_attribute(:api_url, 'invalid_url')
      end

      it 'adds usage of the rest' do
        worker.perform

        expect(Gitlab::UsageDataCounters::NetworkPolicyCounter.totals).to eq(network_policy_drops: 10, network_policy_forwards: 144)
      end
    end
  end
end
