# frozen_string_literal: true

module SubscriptionPortalHelpers
  include StubRequests

  def stub_eoa_eligibility_request(namespace_id, eligible = false, free_upgrade_plan_id = nil, assisted_upgrade_plan_id = nil)
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/graphql", method: :post)
      .with(
        body: "{\"query\":\"{\\n  subscription(namespaceId: \\\"#{namespace_id}\\\") {\\n    eoaStarterBronzeEligible\\n    assistedUpgradePlanId\\n    freeUpgradePlanId\\n  }\\n}\\n\"}",
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'X-Admin-Email' => EE::SUBSCRIPTION_PORTAL_ADMIN_EMAIL,
          'X-Admin-Token' => EE::SUBSCRIPTION_PORTAL_ADMIN_TOKEN
        }
      )
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: stubbed_eoa_eligibility_response_body(eligible, free_upgrade_plan_id, assisted_upgrade_plan_id)
      )
  end

  private

  def stubbed_eoa_eligibility_response_body(eligible, free_upgrade_plan_id, assisted_upgrade_plan_id)
    {
      "data": {
        "subscription": {
          "eoaStarterBronzeEligible": eligible,
          "assistedUpgradePlanId": free_upgrade_plan_id,
          "freeUpgradePlanId": assisted_upgrade_plan_id
        }
      }
    }.to_json
  end
end
