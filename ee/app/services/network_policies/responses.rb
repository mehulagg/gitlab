# frozen_string_literal: true

module NetworkPolicies
  module Responses
    def kubernetes_error_response(error, payload = {})
      ServiceResponse.error(
        http_status: :bad_request,
        message: s_('NetworkPolicies|Kubernetes error: %{error}') % { error: error },
        payload: payload
      )
    end

    def empty_resource_response
      ServiceResponse.error(
        http_status: :bad_request,
        message: s_('NetworkPolicies|Invalid or empty policy')
      )
    end

    def no_platform_response
      ServiceResponse.error(
        http_status: :bad_request,
        message: s_('NetworkPolicies|Environment does not have deployment platform')
      )
    end

    def unsupported_policy_kind
      ServiceResponse.error(
        http_status: :bad_request,
        message: s_('NetworkPolicies|Invalid or unsupported policy kind')
      )
    end
  end
end
