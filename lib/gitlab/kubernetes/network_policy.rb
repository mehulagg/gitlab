# frozen_string_literal: true

module Gitlab
  module Kubernetes
    class NetworkPolicy < NetworkPolicyCommon
      # rubocop:disable Metrics/ParameterLists
      def initialize(name:, namespace:, resource_version:, selector:, ingress:, labels: nil, creation_timestamp: nil, policy_types: ["Ingress"], egress: nil)
        super(name: name, namespace: namespace, resource_version: resource_version, selector: selector, labels: labels, creation_timestamp: creation_timestamp, ingress: ingress, egress: egress)
        @policy_types = policy_types
      end

      def self.from_yaml(manifest)
        return unless manifest

        policy = YAML.safe_load(manifest, symbolize_names: true)
        return if !policy[:metadata] || !policy[:spec]

        metadata = policy[:metadata]
        spec = policy[:spec]
        self.new(
          name: metadata[:name],
          namespace: metadata[:namespace],
          resource_version: metadata[:resourceVersion],
          labels: metadata[:labels],
          selector: spec[:podSelector],
          policy_types: spec[:policyTypes],
          ingress: spec[:ingress],
          egress: spec[:egress]
        )
      rescue Psych::SyntaxError, Psych::DisallowedClass
        nil
      end

      def self.from_resource(resource)
        return unless resource
        return if !resource[:metadata] || !resource[:spec]

        metadata = resource[:metadata]
        spec = resource[:spec].to_h
        self.new(
          name: metadata[:name],
          namespace: metadata[:namespace],
          resource_version: metadata[:resourceVersion],
          labels: metadata[:labels]&.to_h,
          creation_timestamp: metadata[:creationTimestamp],
          selector: spec[:podSelector],
          policy_types: spec[:policyTypes],
          ingress: spec[:ingress],
          egress: spec[:egress]
        )
      end

      private

      attr_reader :policy_types
      def spec
        {
          podSelector: selector,
          policyTypes: policy_types,
          ingress: ingress,
          egress: egress
        }
      end
    end
  end
end
