# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NetworkPolicies::DeleteResourceService do
  let(:service) { NetworkPolicies::DeleteResourceService.new(resource_name: 'policy', environment: environment, manifest: manifest) }
  let(:environment) { instance_double('Environment', deployment_platform: platform, deployment_namespace: 'namespace') }
  let(:platform) { instance_double('Clusters::Platforms::Kubernetes', kubeclient: kubeclient) }
  let(:kubeclient) { double('Kubeclient::Client') }
  let(:manifest) do
    <<~POLICY
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: example-name
        namespace: example-namespace
      spec:
        podSelector:
          matchLabels:
            role: db
        policyTypes:
        - Ingress
        ingress:
        - from:
          - namespaceSelector:
              matchLabels:
                project: myproject
    POLICY
  end

  include_examples 'different network policy types'

  describe '#execute' do
    subject { service.execute }

    it 'deletes resource from the deployment namespace and returns success response' do
      expect(kubeclient).to receive(:delete_network_policy).with('policy', environment.deployment_namespace)
      expect(subject).to be_success
    end

    context 'without deployment_platform' do
      let(:platform) { nil }

      it 'returns error response' do
        expect(subject).to be_error
        expect(subject.http_status).to eq(:bad_request)
        expect(subject.message).not_to be_nil
      end
    end

    context 'with Kubeclient::HttpError' do
      let(:request_url) { 'https://kubernetes.local' }
      let(:response) {  RestClient::Response.create('', {}, RestClient::Request.new(url: request_url, method: :get)) }

      before do
        allow(kubeclient).to receive(:delete_network_policy).and_raise(Kubeclient::HttpError.new(500, 'system failure', response))
      end

      it 'returns error response' do
        expect(subject).to be_error
        expect(subject.http_status).to eq(:bad_request)
        expect(subject.message).not_to be_nil
      end

      it 'returns error message without request url' do
        expect(subject.message).not_to include(request_url)
      end
    end

    context 'with CiliumNetworkPolicy' do
      let(:manifest) do
        <<~POLICY
          apiVersion: cilium.io/v2
          kind: CiliumNetworkPolicy
          metadata:
            name: example-name
            namespace: example-namespace
            resourceVersion: 101
          spec:
            endpointSelector:
              matchLabels:
                role: db
            ingress:
            - fromEndpoints:
              - matchLabels:
                  project: myproject
        POLICY
      end

      it 'deletes resource from the deployment namespace and returns success response' do
        expect(kubeclient).to receive(:delete_cilium_network_policy).with('policy', environment.deployment_namespace)
        expect(subject).to be_success
      end
    end
  end
end
