# frozen_string_literal: true

module EE
  module ServicePing
    module PermitDataCategoriesService
      extend ::Gitlab::Utils::Override

      STANDARD_CATEGORY = ::ServicePing::PermitDataCategoriesService::STANDARD_CATEGORY
      SUBSCRIPTION_CATEGORY = ::ServicePing::PermitDataCategoriesService::SUBSCRIPTION_CATEGORY
      OPTIONAL_CATEGORY = ::ServicePing::PermitDataCategoriesService::OPTIONAL_CATEGORY
      OPERATIONAL_CATEGORY = ::ServicePing::PermitDataCategoriesService::OPERATIONAL_CATEGORY

      override :execute
      def execute
        return [] if ::User.single_user&.requires_usage_stats_consent?
        return super unless ::License.current.present?

        optional_enabled = ::Gitlab::CurrentSettings.usage_ping_enabled?
        operational_enabled = ::License.current&.usage_ping?

        return [] if !optional_enabled && !operational_enabled

        categories = [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY]
        categories << OPTIONAL_CATEGORY if optional_enabled
        categories << OPERATIONAL_CATEGORY if operational_enabled
        categories
      end
    end
  end
end
