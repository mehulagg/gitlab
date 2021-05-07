# frozen_string_literal: true

module NetworkPolicies
  class DeleteResourceService
    include NetworkPolicies::Responses
    include NetworkPolicies::Types

    def initialize(resource_name:, manifest:, environment:)
      @resource_name = resource_name
      @platform = environment.deployment_platform
      @kubernetes_namespace = environment.deployment_namespace
      @has_cilium_policy = cilium_policy?(manifest)
    end

    def execute
      return no_platform_response unless @platform

      if @has_cilium_policy
        @platform.kubeclient.delete_cilium_network_policy(@resource_name, @kubernetes_namespace)
      else
        @platform.kubeclient.delete_network_policy(@resource_name, @kubernetes_namespace)
      end

      ServiceResponse.success
    rescue Kubeclient::HttpError => e
      kubernetes_error_response(e.message)
    end
  end
end
