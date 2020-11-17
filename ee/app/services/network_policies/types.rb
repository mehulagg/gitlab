# frozen_string_literal: true

module NetworkPolicies
  module Types
    def cilium_policy?(manifest)
      manifest&.include?(Gitlab::Kubernetes::CiliumNetworkPolicy::KIND)
    end

    def policy_from_manifest(manifest)
      cilium_policy?(manifest) ? Gitlab::Kubernetes::CiliumNetworkPolicy.from_yaml(manifest) : Gitlab::Kubernetes::NetworkPolicy.from_yaml(manifest)
    end
  end
end
