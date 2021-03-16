# frozen_string_literal: true

module Gitlab
  class JWTToken < JSONWebToken::HMACToken
    HMAC_ALGORITHM = 'SHA256'.freeze
    HMAC_KEY = 'gitlab-jwt'.freeze
    HMAC_DEFAULT_EXPIRES_IN = 5.minutes.freeze

    class << self
      def decode(jwt, expires_in: HMAC_DEFAULT_EXPIRES_IN)
        payload = super(jwt, secret).first

        new(access_token_id: payload['access_token'], user_id: payload['user_id'])
      rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::ImmatureSignature
        # we want to simply return on expired and errored tokens
      end

      def secret
        OpenSSL::HMAC.hexdigest(
          HMAC_ALGORITHM,
          ::Settings.attr_encrypted_db_key_base,
          HMAC_KEY
        )
      end
    end

    def initialize(access_token_id:, user_id:, expires_in: HMAC_DEFAULT_EXPIRES_IN)
      super(self.class.secret)
      self['access_token'] = access_token_id
      self['user_id'] = user_id
      self.expire_time = self.issued_at + expires_in
    end

    def access_token
      access_token = PersonalAccessToken.find_by_token(self['access_token'])
      access_token ||= DeployToken.find_by_token(self['access_token'])
      access_token ||= Ci::Build.find_by_token(self['access_token'])
      access_token
    end

    def user
      return User.find(self['user_id']) if self['user_id'].is_a?(Integer)

      access_token
    end
  end
end
