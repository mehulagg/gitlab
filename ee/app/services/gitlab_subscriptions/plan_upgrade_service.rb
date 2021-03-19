# frozen_string_literal: true

module GitlabSubscriptions
  class PlanUpgradeService
    def initialize(namespace_id:)
      @namespace_id = namespace_id
    end

    def execute
      result = client.plan_upgrade_offer(@namespace_id)

      plan_id = result[:assisted_upgrade_plan_id] || result[:free_upgrade_plan_id] unless result[:eligible_for_free_upgrade].nil?

      {
         upgrade_for_free: result[:eligible_for_free_upgrade],
         upgrade_plan_id: plan_id
       }
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end
  end
end
