# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    module Clients
      class Graphql < BaseClient
        class << self
          def execute(query, headers: admin_headers, variables: {})
            response = ::Gitlab::HTTP.post(
              "#{base_url}/graphql",
              headers: headers,
              body: {
                query: query,
                variables: variables
              }.to_json
            )

            parse_response(response)
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

            response = execute(query).dig(:data, 'data', 'cloudActivationActivate')

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

            response = execute(query).dig(:data)

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
        end
      end
    end
  end
end
