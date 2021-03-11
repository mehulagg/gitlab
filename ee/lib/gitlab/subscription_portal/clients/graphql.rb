# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    module Clients
      module Graphql
        extend ActiveSupport::Concern

        class_methods do
          def activate(activation_code)
            uuid = Gitlab::CurrentSettings.uuid

            variables = {
              activationCode: activation_code,
              instanceIdentifier: uuid
            }

            query = <<~GQL
              mutation($activationCode: String!, $instanceIdentifier: String!) {
                cloudActivationActivate(
                  input: {
                    activationCode: $activationCode,
                    instanceIdentifier: $instanceIdentifier
                  }
                ) {
                  licenseKey
                  errors
                }
              }
            GQL

            response = execute_graphql_query(
              { query: query, variables: variables }
            )

            if !response[:success] || response.dig(:data, 'errors').present?
              return { success: false, errors: response.dig(:data, 'errors') }
            end

            response = response.dig(:data, 'data', 'cloudActivationActivate')

            if response['errors'].blank?
              { success: true, license_key: response['licenseKey'] }
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

            response = execute_graphql_query({ query: query }).dig(:data)

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

          private

          def execute_graphql_query(params)
            response = ::Gitlab::HTTP.post(
              graphql_endpoint,
              headers: admin_headers,
              body: params.to_json
            )

            parse_response(response)
          end

          def graphql_endpoint
            EE::SUBSCRIPTIONS_GRAPHQL_URL
          end
        end
      end
    end
  end
end
