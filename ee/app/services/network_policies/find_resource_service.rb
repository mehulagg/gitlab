# frozen_string_literal: true

module NetworkPolicies
  class FindResourceService
    include NetworkPolicies::Responses

    def initialize(resource_name:, environment:, kind: Gitlab::Kubernetes::NetworkPolicy::KIND)
      @resource_name = resource_name
      @platform = environment.deployment_platform
      @kubernetes_namespace = environment.deployment_namespace
      @kind = kind
    end

    def execute
      return no_platform_response unless @platform

      policy = get_policy
      return unsupported_policy_kind if policy.blank?

      ServiceResponse.success(payload: policy)
    rescue Kubeclient::HttpError => e
      kubernetes_error_response(e.message)
    end

    private

    def get_policy
      client = @platform.kubeclient
      if @kind == Gitlab::Kubernetes::CiliumNetworkPolicy::KIND
        resource = client.get_cilium_network_policy(@resource_name, @kubernetes_namespace)
        Gitlab::Kubernetes::CiliumNetworkPolicy.from_resource(resource)
      elsif @kind == Gitlab::Kubernetes::NetworkPolicy::KIND
        resource = client.get_network_policy(@resource_name, @kubernetes_namespace)
        Gitlab::Kubernetes::NetworkPolicy.from_resource(resource)
      end
    end
  end
end
