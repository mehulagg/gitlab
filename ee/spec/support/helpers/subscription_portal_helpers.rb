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

  def stub_plan_data_request(plan_tags)
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/graphql", method: :post)
      .with(
        body: include(*plan_tags, *stubbed_plan_data_query_fields_camelized),
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
        body: stubbed_plan_data_response_body
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

  def stubbed_plan_data_query_fields
    %w[
      name
      code
      active
      free
      price_per_month
      price_per_year
      features
      about_page_href
      hide_deprecated_card
    ]
  end

  def stubbed_plan_data_query_fields_camelized
    stubbed_plan_data_query_fields.map { |field| field.to_s.camelize(:lower) }
  end

  def stubbed_plan_data_response_body
    {
      "data": {
        "plans": [
          {
            "name": "1000 CI minutes pack",
            "code": "ci_minutes",
            "active": true,
            "deprecated": false,
            "free": nil,
            "price_per_month": 0.8333333333333334,
            "price_per_year": 10,
            "features": nil,
            "about_page_href": nil,
            "hide_deprecated_card": false
          },
          {
            "name": "Deprecated 1000 CI minutes pack",
            "code": "deprecated_ci_minutes",
            "active": true,
            "deprecated": true,
            "free": nil,
            "price_per_month": 1,
            "price_per_year": 12,
            "features": nil,
            "about_page_href": nil,
            "hide_deprecated_card": false
          }
        ]
      }
    }.to_json
  end
end
