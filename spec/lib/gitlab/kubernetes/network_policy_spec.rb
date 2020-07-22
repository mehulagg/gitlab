# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Kubernetes::NetworkPolicy do
  let(:policy) do
    described_class.new(
      name: name,
      namespace: namespace,
      creation_timestamp: '2020-04-14T00:08:30Z',
      resource_version: resource_version,
      selector: pod_selector,
      policy_types: %w(Ingress Egress),
      ingress: ingress,
      egress: egress
    )
  end

  let(:resource_version) { 101 }
  let(:name) { 'example-name' }
  let(:namespace) { 'example-namespace' }
  let(:pod_selector) { { matchLabels: { role: 'db' } } }
  let(:partial_class_name) { described_class.name.split('::').last }

  let(:ingress) do
    [
      {
        from: [
          { namespaceSelector: { matchLabels: { project: 'myproject' } } }
        ]
      }
    ]
  end

  let(:egress) do
    [
      {
        ports: [{ port: 5978 }]
      }
    ]
  end

  describe '.from_yaml' do
    let(:manifest) do
      <<~POLICY
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: example-name
          namespace: example-namespace
          resourceVersion: 101
          labels:
            app: foo
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
    let(:resource) do
      ::Kubeclient::Resource.new(
        kind: partial_class_name,
        metadata: { name: name, namespace: namespace, labels: { app: 'foo' }, resourceVersion: resource_version },
        spec: { podSelector: pod_selector, policyTypes: %w(Ingress), ingress: ingress, egress: nil }
      )
    end

    subject { Gitlab::Kubernetes::NetworkPolicy.from_yaml(manifest)&.generate }

    it { is_expected.to eq(resource) }

    context 'with nil manifest' do
      let(:manifest) { nil }

      it { is_expected.to be_nil }
    end

    context 'with invalid manifest' do
      let(:manifest) { "\tfoo: bar" }

      it { is_expected.to be_nil }
    end

    context 'with manifest without metadata' do
      let(:manifest) do
        <<~POLICY
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
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

      it { is_expected.to be_nil }
    end

    context 'with manifest without spec' do
      let(:manifest) do
        <<~POLICY
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: example-name
          namespace: example-namespace
        POLICY
      end

      it { is_expected.to be_nil }
    end

    context 'with disallowed class' do
      let(:manifest) do
        <<~POLICY
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: example-name
          namespace: example-namespace
          creationTimestamp: 2020-04-14T00:08:30Z
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

      it { is_expected.to be_nil }
    end
  end

  describe '.from_resource' do
    let(:resource) do
      ::Kubeclient::Resource.new(
        kind: partial_class_name,
        metadata: {
          name: name, namespace: namespace, creationTimestamp: '2020-04-14T00:08:30Z',
          labels: { app: 'foo' }, resourceVersion: resource_version
        },
        spec: { podSelector: pod_selector, policyTypes: %w(Ingress), ingress: ingress, egress: nil }
      )
    end
    let(:generated_resource) do
      ::Kubeclient::Resource.new(
        kind: partial_class_name,
        metadata: { name: name, namespace: namespace, labels: { app: 'foo' }, resourceVersion: resource_version },
        spec: { podSelector: pod_selector, policyTypes: %w(Ingress), ingress: ingress, egress: nil }
      )
    end

    subject { Gitlab::Kubernetes::NetworkPolicy.from_resource(resource)&.generate }

    it { is_expected.to eq(generated_resource) }

    context 'with nil resource' do
      let(:resource) { nil }

      it { is_expected.to be_nil }
    end

    context 'with resource without metadata' do
      let(:resource) do
        ::Kubeclient::Resource.new(
          spec: { podSelector: pod_selector, policyTypes: %w(Ingress), ingress: ingress, egress: nil }
        )
      end

      it { is_expected.to be_nil }
    end

    context 'with resource without spec' do
      let(:resource) do
        ::Kubeclient::Resource.new(
          metadata: { name: name, namespace: namespace, uid: '128cf288-7de4-11ea-aceb-42010a800089', resourceVersion: resource_version }
        )
      end

      it { is_expected.to be_nil }
    end
  end
end
