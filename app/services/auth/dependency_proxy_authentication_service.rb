# frozen_string_literal: true

module Auth
  class DependencyProxyAuthenticationService < BaseService
    AUDIENCE = 'dependency_proxy'.freeze
    HMAC_KEY = 'gitlab-dependency-proxy'.freeze

    def execute(authentication_abilities:)
      @authentication_abilities = authentication_abilities

      return error('UNAVAILABLE', status: 404, message: 'dependency proxy not enabled') unless ::Gitlab.config.dependency_proxy.enabled

      return error('DENIED', status: 403, message: 'access forbidden') unless current_user

      { token: authorized_token.encoded }
    end

    class << self
      def secret
        OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest::SHA256.new,
          ::Settings.attr_encrypted_db_key_base,
          HMAC_KEY
        )
      end
    end

    private

    def authorized_token
      JSONWebToken::HMACToken.new(self.class.secret).tap do |token|
        token['user_id'] = current_user.id
      end
    end
  end
end
