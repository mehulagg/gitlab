# frozen_string_literal: true

# The Conan client uses a JWT for authenticating with remotes.
# This class encodes and decodes a user's personal access token or
# CI_JOB_TOKEN into a JWT that is used by the Conan client to
# authenticate with GitLab

module Gitlab
  class ConanToken < JWTToken
    HMAC_EXPIRES_IN = 1.hour.freeze

    attr_reader :access_token_id, :user_id

    class << self
      def from_personal_access_token(access_token)
        new(access_token_id: access_token.id, user_id: access_token.user_id)
      end

      def from_job(job)
        new(access_token_id: job.token, user_id: job.user.id)
      end

      def from_deploy_token(deploy_token)
        new(access_token_id: deploy_token.token, user_id: deploy_token.username)
      end

      def decode(jwt)
        super(jwt, expires_in: HMAC_EXPIRES_IN)
      end
    end

    def initialize(access_token_id:, user_id:)
      @access_token_id = access_token_id
      @user_id = user_id
      super(access_token_id: @access_token_id, user_id: @user_id, expires_in: HMAC_EXPIRES_IN)
    end

    alias_method :to_jwt, :encoded
  end
end
