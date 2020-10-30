# frozen_string_literal: true

module Security
  # Service for alerting revocation service of leaked security tokens
  #
  class TokenRevocationService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    RevocationFailedError = Class.new(StandardError)

    attr_reader :revocable_keys

    def initialize(revocable_keys:)
      @revocable_keys = revocable_keys
    end

    def execute
      return error('Token revocation is disabled') unless token_revocation_enabled?

      response = revoke_tokens
      response.code == 200 ? success : error("Failed to revoke tokens")
    rescue RevocationFailedError => exception
      error(exception.message)
    rescue StandardError => exception
      log_token_revocation_error(exception)
      error(exception.message)
    end

    private

    def token_revocation_enabled?
      ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled
    end

    def revoke_tokens
      ::Gitlab::HTTP.post(
        ::Gitlab::CurrentSettings.secret_detection_token_revocation_url,
        body: message,
        headers: {
         'Content-Type' => 'application/json',
         'X-Token' => ::Gitlab::CurrentSettings.secret_detection_token_revocation_token
        }
      )
    end

    def log_token_revocation_error(error)
      log_error(
        error: error.class.name,
        message: error.message,
        source: "#{__FILE__}:#{__LINE__}",
        backtrace: error.backtrace
      )
    end

    def message
      response = ::Gitlab::HTTP.get(
        ::Gitlab::CurrentSettings.secret_detection_revocation_token_types_url,
        headers: {
          'Content-Type' => 'application/json',
          'X-Token' => ::Gitlab::CurrentSettings.secret_detection_revocation_token_types_token
        }
      )
      raise RevocationFailedError, "Failed to get revocation token types" unless response.success?

      token_types = ::Gitlab::Json.parse(response.body)["types"]
      @revocable_keys = @revocable_keys.filter { |key| token_types.include?(key[:type]) }
      raise RevocationFailedError, "No revocable key is present" if @revocable_keys.empty?

      @revocable_keys.to_json
    end
  end
end
