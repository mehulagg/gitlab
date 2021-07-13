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
        return super unless ::License.current.present?
        return [] unless product_intelligence_enabled?

        optional_enabled = ::Gitlab::CurrentSettings.usage_ping_enabled?
        customer_service_enabled = ::License.current.usage_ping?

        [STANDARD_CATEGORY, SUBSCRIPTION_CATEGORY].tap do |categories|
          categories << OPERATIONAL_CATEGORY << OPTIONAL_CATEGORY if optional_enabled
          categories << OPERATIONAL_CATEGORY if customer_service_enabled
        end.to_set
      end

      private

      override :pings_enabled?
      def pings_enabled?
        ::License.current&.usage_ping? || super
      end
    end
  end
end
