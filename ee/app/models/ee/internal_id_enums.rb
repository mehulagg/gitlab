# frozen_string_literal: true

module EE
  module InternalIdEnums
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :usage_resources
      def usage_resources
        super.merge({
          requirements: 1000,
          quality_test_cases: 1001
        })
      end
    end
  end
end
