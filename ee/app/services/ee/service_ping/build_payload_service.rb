# frozen_string_literal: true

module EE
  module ServicePing
    module BuildPayloadService
      extend ::Gitlab::Utils::Override

      STANDARD_CATEGORY = ::ServicePing::BuildPayloadService::STANDARD_CATEGORY
      SUBSCRIPTION_CATEGORY = ::ServicePing::BuildPayloadService::SUBSCRIPTION_CATEGORY
      OPTIONAL_CATEGORY = ::ServicePing::BuildPayloadService::OPTIONAL_CATEGORY
      OPERATIONAL_CATEGORY = ::ServicePing::BuildPayloadService::OPERATIONAL_CATEGORY

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
        return [] if !optional_enabled && !operational_enabled

        categories = [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY]
        categories << OPTIONAL_CATEGORY if optional_enabled
        categories << OPERATIONAL_CATEGORY if operational_enabled
        categories
      end
    end
  end
end
