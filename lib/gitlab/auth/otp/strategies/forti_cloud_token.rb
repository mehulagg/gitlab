# frozen_string_literal: true

module Gitlab
  module Auth
    module Otp
      module Strategies
        class FortiCloudToken < Base
          include Gitlab::Utils::StrongMemoize

          def validate(otp_code)
            # TODO: Access tokens are valid for 60 minutes by default,
            # so if we can cache this token upon a successful request to `/login`,
            # we can avoid this request (to `/login`) for the next 60 minutes and only make the call
            # to `/auth` with the already cached access token.

            if access_token_create_response.created?
              otp_verification_response = verify_otp(otp_code)

              otp_verification_response.ok? ? success : error_from_response(otp_verification_response)
            else
              error_from_response(access_token_create_response)
            end
          end

          private

          def access_token_create_response
            # Returns '201 CREATED' on successful creation of a new access token.
            strong_memoize(:access_token_create_response) do
              post(
                url: url('/login'),
                body: {
                        client_id: ::Gitlab.config.forti_token_cloud.client_id,
                        client_secret: ::Gitlab.config.forti_token_cloud.client_secret
                }.to_json
              )
            end
          end

          def access_token
            access_token_create_response['access_token']
          end

          def verify_otp(otp_code)
            # Returns '200 OK' on successful verification.
            # Uses the access token created via `access_token_create_response` as the auth token.
            post(
              url: url('/auth'),
              headers: { 'Authorization': "Bearer #{access_token}" },
              body: {
                      username: user.username,
                      token: otp_code
              }.to_json
            )
          end

          def url(path)
            base_url + path
          end

          def base_url
            strong_memoize(:base_url) do
              ::Gitlab.config.forti_token_cloud.url
            end
          end

          def post(url:, body:, headers: {})
            Gitlab::HTTP.post(
              url,
              headers: {
                'Content-Type': 'application/json'
              }.merge(headers),
              body: body,
              verify: false # FTC API Docs specifically mentions to turn off SSL Verification while making requests.
            )
          end
        end
      end
    end
  end
end
