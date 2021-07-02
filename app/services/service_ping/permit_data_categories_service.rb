# frozen_string_literal: true

module ServicePing
  class PermitDataCategoriesService
    STANDARD_CATEGORY = 'Standard'
    SUBSCRIPTION_CATEGORY = 'Subscription'
    OPERATIONAL_CATEGORY = 'Operational'
    OPTIONAL_CATEGORY = 'Optional'

    def execute
      return [] if User.single_user&.requires_usage_stats_consent?
      return [] unless ::Gitlab::CurrentSettings.usage_ping_enabled?

      [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY, OPERATIONAL_CATEGORY, OPTIONAL_CATEGORY]
    end
  end
end

ServicePing::PermitDataCategoriesService.prepend_mod_with('ServicePing::PermitDataCategoriesService')
