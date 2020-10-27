# frozen_string_literal: true

module Security
  # Service for alerting revocation service of leaked security tokens
  #
  class TokenRevocationService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :revocable_keys

    def initialize(revocable_keys:)
      @revocable_keys = revocable_keys
    end

    def execute
      return error('Token revocation is disabled') unless ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled

      ::Gitlab::HTTP.post(
        Gitlab::CurrentSettings.secret_detection_token_revocation_url,
        body: revocable_keys.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-Token' => Gitlab::CurrentSettings.secret_detection_token_revocation_token
        }
      )

      success
    rescue StandardError => error
      log_error(
        error: error.class.name,
        message: error.message,
        source: "#{__FILE__}:#{__LINE__}",
        backtrace: error.backtrace
      )
      error("Failed to revoke tokens")
    end
  end
end
