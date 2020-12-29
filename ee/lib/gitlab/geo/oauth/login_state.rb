# frozen_string_literal: true

module Gitlab
  module Geo
    module Oauth
      class LoginState
        def self.from_state(state)
          salt, token = state.to_s.split(':', 2)
          self.new(salt: salt, token: token)
        end

        def initialize(salt: nil, token: nil)
          @salt = salt
          @token = token
        end

        def encode
          "#{salt}:#{hmac_token}"
        end

        def valid?
          return false unless salt.present? && token.present?

          decoded_token = JSONWebToken::HMACToken.decode(token, key).first
          decoded_token[:data] == 'ok'
        rescue JWT::DecodeError
          false
        end

        private

        attr_reader :token

        def expiration_time
          1.minute
        end

        def hmac_token
          hmac_token = JSONWebToken::HMACToken.new(key)
          hmac_token.expire_time = Time.now + expiration_time
          hmac_token[:data] = 'ok'
          hmac_token.encoded
        end

        def key
          ActiveSupport::KeyGenerator
            .new(Gitlab::Application.secrets.secret_key_base)
            .generate_key(salt)
        end

        def salt
          @salt ||= SecureRandom.hex(8)
        end
      end
    end
  end
end
