# frozen_string_literal: true

RSpec.shared_examples 'different network policy types' do
  let(:network_policy_manifest) do
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

  let(:cilium_network_policy_manifest) do
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

  describe 'cilium_policy?' do
    subject { service.cilium_policy?(manifest) }

    context 'with nil as parameter' do
      let(:manifest) { nil }

      it { is_expected.to be_nil }
    end

    context 'with a manifest of NetworkPolicy' do
      let(:manifest) { network_policy_manifest }

      it { is_expected.to be false }
    end

    context 'with a manifest of CiliumNetworkPolicy' do
      let(:manifest) { cilium_network_policy_manifest }

      it { is_expected.to be true }
    end
  end

  describe 'policy_from_manifest' do
    subject { service.policy_from_manifest(manifest) }

    context 'with a manifest of a NetworkPolicy' do
      let(:manifest) { network_policy_manifest }

      it { is_expected.to be_an_instance_of Gitlab::Kubernetes::NetworkPolicy }
    end

    context 'with a manifest of a CiliumNetworkPolicy' do
      let(:manifest) { cilium_network_policy_manifest }

      it { is_expected.to be_an_instance_of Gitlab::Kubernetes::CiliumNetworkPolicy }
    end
  end
end
