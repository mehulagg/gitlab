# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    class Client
      class << self
        def generate_trial(params)
          http_post("trials", admin_headers, params)
        end

        def create_customer(params)
          http_post("api/customers", admin_headers, params)
        end

        def create_subscription(params, email, token)
          http_post("subscriptions", customer_headers(email, token), params)
        end

        def payment_form_params(payment_type)
          http_get("payment_forms/#{payment_type}", admin_headers)
        end

        def payment_method(id)
          http_get("api/payment_methods/#{id}", admin_headers)
        end

        private

        def http_get(path, headers)
          response = Gitlab::HTTP.get("#{base_url}/#{path}", headers: headers)

          parse_response(response)
        rescue *Gitlab::HTTP::HTTP_ERRORS => e
          { success: false, data: { errors: e.message } }
        end

        def http_post(path, headers, params = {})
          response = Gitlab::HTTP.post("#{base_url}/#{path}", body: params.to_json, headers: headers)

          parse_response(response)
        rescue *Gitlab::HTTP::HTTP_ERRORS => e
          { success: false, data: { errors: e.message } }
        end

        def base_url
          EE::SUBSCRIPTIONS_URL
        end

        def json_headers
          {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          }
        end

        def admin_headers
          json_headers.merge(
            {
              'X-Admin-Email' => EE::SUBSCRIPTION_PORTAL_ADMIN_EMAIL,
              'X-Admin-Token' => EE::SUBSCRIPTION_PORTAL_ADMIN_TOKEN
            }
          )
        end

        def customer_headers(email, token)
          json_headers.merge(
            {
              'X-Customer-Email' => email,
              'X-Customer-Token' => token
            }
          )
        end

        def parse_response(http_response)
          parsed_response = http_response.parsed_response

          case http_response.response
          when Net::HTTPSuccess
            { success: true, data: parsed_response }
          when Net::HTTPUnprocessableEntity
            { success: false, data: { errors: parsed_response['errors'] } }
          else
            { success: false, data: { errors: "HTTP status code: #{http_response.code}" } }
          end
        end
      end
    end
  end
end
