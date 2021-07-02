# frozen_string_literal: true

module EE
  module ServicePing
    module BuildPayloadService
      extend ::Gitlab::Utils::Override

      private

      override :product_intelligence_enabled?
      def product_intelligence_enabled?
        ::License.current&.usage_ping? || super
      end
    end
  end
end
