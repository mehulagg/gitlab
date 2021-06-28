# frozen_string_literal: true

module EE
  module ProductIntelligence
    module CollectServicePingService
      extend ::Gitlab::Utils::Override

      STANDARD_CATEGORY = ::ProductIntelligence::CollectServicePingService::STANDARD_CATEGORY
      SUBSCRIPTION_CATEGORY = ::ProductIntelligence::CollectServicePingService::SUBSCRIPTION_CATEGORY
      OPTIONAL_CATEGORY = ::ProductIntelligence::CollectServicePingService::OPTIONAL_CATEGORY
      OPERATIONAL_CATEGORY = ::ProductIntelligence::CollectServicePingService::OPERATIONAL_CATEGORY

      private

      override :product_intelligence_enabled?
      def product_intelligence_enabled?
        ::License.current&.usage_ping? || super
      end

      override :filter_permitted_categories
      def filter_permitted_categories
        optional_enabled = ::Gitlab::CurrentSettings.usage_ping_enabled?
        operational_enabled = ::License.current&.usage_ping?

        return super unless ::License.current.present?

        if optional_enabled && operational_enabled
          [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY, OPTIONAL_CATEGORY, OPERATIONAL_CATEGORY]
        elsif optional_enabled && !operational_enabled
          [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY, OPTIONAL_CATEGORY]
        elsif !optional_enabled && operational_enabled
          [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY, OPERATIONAL_CATEGORY]
        else
          []
        end
      end
    end
  end
end
