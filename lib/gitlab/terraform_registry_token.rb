# frozen_string_literal: true

module Gitlab
  class TerraformRegistryToken < JWTToken
    class << self
      def from_token(token)
        access_token_id = token.token if token.respond_to?(:token)
        access_token_id ||= token.id if token.respond_to?(:id)

        user_id = token.user_id if token.respond_to?(:user_id)
        user_id ||= token.user.id if token.respond_to?(:user)
        user_id ||= token.username if token.respond_to?(:username)

        new(access_token_id: access_token_id, user_id: user_id)
      end
    end
  end
end
