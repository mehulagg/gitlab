# frozen_string_literal: true

module GitlabSubscriptions
  class EligibleForFreeUpgradeService

    def initialize(namespace_id:)
      @namespace_id = namespace_id
    end

    def execute
      result = client.eligible_for_upgrade_offer(@namespace_id)

      result[:success] ? result[:eligible_for_free_upgrade] : false
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end
  end
end
