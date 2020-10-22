# frozen_string_literal: true

module Security
  # Service for alerting revocation service of leaked security tokens
  #
  class TokenRevocationService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :build, :revocable_keys

    def initialize(build_id:, revocable_keys:)
      @build = Ci::Build.find_by_id(build_id)
      @revocable_keys = revocable_keys
    end

    def execute
      return nil unless ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled

      ::Gitlab::HTTP.post(
        Gitlab::CurrentSettings.secret_detection_token_revocation_url,
        body: message.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-Token' => Gitlab::CurrentSettings.secret_detection_token_revocation_token
        }
      )

      success
    end

    private

    def message
      revocable_keys.map do |key|
        {
          key_type: key.type,
          key_value: key.value,
          # permalink to SHA URL
          key_location: key.location
        }
      end
    end
  end
end
