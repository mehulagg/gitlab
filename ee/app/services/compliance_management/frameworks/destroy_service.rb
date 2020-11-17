# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class DestroyService < BaseService
      def initialize(framework:, current_user:)
        @framework = framework
        @current_user = current_user
      end

      def execute
        return ServiceResponse.error(message: _('Feature not available')) unless permitted?

        @framework.destroy! ? success : error
      end

      private

      def permitted?
        License.feature_available?(:custom_compliance_frameworks) && @framework.namespace.owner == @current_user
      end

      def success
        ServiceResponse.success(message: _('Framework successfully deleted'))
      end

      def error
        ServiceResponse.error(message: _('Failed to create framework'), payload: @framework.errors )
      end
    end
  end
end
