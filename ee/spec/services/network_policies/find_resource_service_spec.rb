# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NetworkPolicies::FindResourceService do
  let(:service) { described_class.new(resource_name: 'policy', environment: environment, kind: kind) }
  let(:environment) { instance_double('Environment', deployment_platform: platform, deployment_namespace: 'namespace') }
  let(:platform) { instance_double('Clusters::Platforms::Kubernetes', kubeclient: kubeclient) }
  let(:kubeclient) { double('Kubeclient::Client') }
  let(:policy) do
    Gitlab::Kubernetes::NetworkPolicy.new(
      name: 'policy',
      namespace: 'another',
      selector: { matchLabels: { role: 'db' } },
      ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
    )
  end

  let(:kind) { Gitlab::Kubernetes::NetworkPolicy::KIND }

  describe '#execute' do
    subject { service.execute }

    it 'returns success response with a requested policy' do
      expect(kubeclient).to(
        receive(:get_network_policy)
          .with('policy', environment.deployment_namespace) { policy.generate }
      )
      expect(subject).to be_success
      expect(subject.payload.as_json).to eq(policy.as_json)
    end

    context 'with CiliumNetworkPolicy kind' do
      let(:kind) { Gitlab::Kubernetes::CiliumNetworkPolicy::KIND }
      let(:policy) do
        Gitlab::Kubernetes::CiliumNetworkPolicy.new(
          name: 'policy',
          namespace: 'another',
          selector: { matchLabels: { role: 'db' } },
          ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
        )
      end

      it 'returns success response with a requested policy' do
        expect(kubeclient).to(
          receive(:get_cilium_network_policy)
            .with('policy', environment.deployment_namespace) { policy.generate }
        )
        expect(subject).to be_success
        expect(subject.payload.as_json).to eq(policy.as_json)
      end
    end

    context 'with invalid policy kind' do
      let(:kind) { 'InvalidKind' }

      it 'returns error response' do
        expect(subject).to be_error
        expect(subject.http_status).to eq(:bad_request)
        expect(subject.message).not_to be_nil
      end
    end

    context 'without deployment_platform' do
      let(:platform) { nil }

      it 'returns error response' do
        expect(subject).to be_error
        expect(subject.http_status).to eq(:bad_request)
        expect(subject.message).not_to be_nil
      end
    end

    include_examples 'responds to Kubeclient::HttpError', :get_network_policy
  end
end
