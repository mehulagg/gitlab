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

        def activate(activation_code)
          uuid = Gitlab::CurrentSettings.uuid

          query = <<~GQL
            mutation {
              cloudActivationActivate(input: { activationCode: "#{activation_code}", instanceIdentifier: "#{uuid}" }) {
                authenticationToken
                errors
              }
            }
          GQL

          response = http_post("graphql", admin_headers, { query: query }).dig(:data, 'data', 'cloudActivationActivate')

          if response['errors'].blank?
            { success: true, authentication_token: response['authenticationToken'] }
          else
            { success: false, errors: response['errors'] }
          end
        end

        def plan_upgrade_offer(namespace_id)
          query = <<~GQL
            {
              subscription(namespaceId: "#{namespace_id}") {
                eoaStarterBronzeEligible
                assistedUpgradePlanId
                freeUpgradePlanId
              }
            }
          GQL

          response = http_post("graphql", admin_headers, { query: query }).dig(:data)

          if response['errors'].blank?
            eligible = response.dig('data', 'subscription', 'eoaStarterBronzeEligible')
            assisted_upgrade = response.dig('data', 'subscription', 'assistedUpgradePlanId')
            free_upgrade = response.dig('data', 'subscription', 'freeUpgradePlanId')

            {
              success: true,
              eligible_for_free_upgrade: eligible,
              assisted_upgrade_plan_id: assisted_upgrade,
              free_upgrade_plan_id: free_upgrade
            }
          else
            { success: false }
          end
        end

        def plan_data(plan_tags)
          query = <<~GQL
            {
              plans(planTags: #{plan_tags}) {
                id,
                name,
                code,
                active,
                deprecated,
                free,
                pricePerMonth,
                pricePerYear,
                features,
                aboutPageHref,
                hideDeprecatedCard,
              }
            }
          GQL

          response = http_post("graphql", admin_headers, { query: query }).dig(:data)

          response['errors'].presence || response.dig('data', 'plans')
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
