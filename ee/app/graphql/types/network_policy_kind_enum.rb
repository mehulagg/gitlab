# frozen_string_literal: true

module Types
  class NetworkPolicyKindEnum < BaseEnum
    graphql_name 'NetworkPolicyKind'
    description 'Kind of the network policy'

    value Gitlab::Kubernetes::CiliumNetworkPolicy::KIND, 'The policy kind of Cilium Network Policy.'
    value Gitlab::Kubernetes::NetworkPolicy::KIND, 'The policy kind of Network Policy.'
  end
end
