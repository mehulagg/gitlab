# frozen_string_literal: true

module Gitlab
  module Auth
    module Otp
      module Strategies
        class FortiAuthenticator < Base
          def validate(otp_code)
            body = { username: user.username,
                     token_code: otp_code }

            post_request(auth_url, body)
          end

          def push_notification
            body = { username: user.username }

            post_request(pushauth_url, body)
          end

          private

          def post_request(url, body)
            response = Gitlab::HTTP.post(
              url,
              headers: { 'Content-Type': 'application/json' },
              body: body.to_json,
              basic_auth: api_credentials)

            # Successful POST results in HTTP 200: OK
            # https://docs.fortinet.com/document/fortiauthenticator/6.2.0/rest-api-solution-guide/704555/authentication-auth
            # https://docs.fortinet.com/document/fortiauthenticator/6.1.1/rest-api-solution-guide/943094/push-authentication-pushauth
            response.ok? ? success : error_from_response(response)
          rescue StandardError => ex
            Gitlab::AppLogger.error(ex)
            error(ex.message)
          end

          def host
            @host ||= ::Gitlab.config.forti_authenticator.host
          end

          def port
            @port ||= ::Gitlab.config.forti_authenticator.port
          end

          def pushauth_url
            path = 'api/v1/pushauth/'

            "https://#{host}:#{port}/#{path}"
          end

          def auth_url
            path = 'api/v1/auth/'

            "https://#{host}:#{port}/#{path}"
          end

          def api_credentials
            { username: ::Gitlab.config.forti_authenticator.username,
              password: ::Gitlab.config.forti_authenticator.access_token }
          end
        end
      end
    end
  end
end
