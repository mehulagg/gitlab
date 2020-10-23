# frozen_string_literal: true

module Auth
  class DependencyProxyAuthenticationService < BaseService
    AUDIENCE = 'dependency_proxy'

    def execute(authentication_abilities:)
      @authentication_abilities = authentication_abilities

      # return error('UNAVAILABLE', status: 404, message: 'dependency proxy not enabled') unless dependency_proxy.enabled

      return error('DENIED', status: 403, message: 'access forbidden') unless current_user

      { token: authorized_token.to_jwt }
    end

    private

    def authorized_token
      ::Gitlab::ConanToken.from_user(current_user)
    end
  end
end
