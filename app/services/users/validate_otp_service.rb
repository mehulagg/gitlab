# frozen_string_literal: true

module Users
  class ValidateOtpService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(otp_code)
      if Feature.enabled?(:forti_authenticator, current_user)
        raise 'boom'
        validate_against_forti_authenticator(otp_code)
      else
        validate_against_devise(otp_code)
      end
    end

    private

    def validate_against_devise(otp_code)
      current_user.validate_and_consume_otp!(otp_code) ? success : error('failure')
    end

    def validate_against_forti_authenticator(otp_code)
      body = { username: current_user.username,
               token_code: otp_code }

      response = Gitlab::HTTP.post(
        forti_authenticator_auth_url,
        headers: { 'Content-Type': 'application/json' },
        body: body.to_json,
        basic_auth: forti_authenticator_basic_auth,
        allow_local_requests: Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?)

      response.ok? ? success : error(message: response.message, http_status: response.code)
    rescue *Gitlab::HTTP::HTTP_ERRORS => ex
      Gitlab::ErrorTracking.log_exception(ex)
    end

    def forti_authenticator_auth_url
      host = ::Gitlab.config.forti_authenticator.host
      port = ::Gitlab.config.forti_authenticator.port
      path = 'api/v1/auth/'

      "https://#{host}:#{port}/#{path}"
    end

    def forti_authenticator_basic_auth
      { username: ::Gitlab.config.forti_authenticator.username,
        password: ::Gitlab.config.forti_authenticator.token }
    end
  end
end
