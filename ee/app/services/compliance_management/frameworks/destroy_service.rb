# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class DestroyService < BaseService
      attr_reader :framework, :current_user

      def initialize(framework:, current_user:)
        @framework = framework
        @current_user = current_user
      end

      def execute
        return ServiceResponse.error(message: _('Not permitted to destroy framework')) unless permitted?

        framework.destroy ? success : error
      end

      private

      def permitted?
        can? current_user, :manage_compliance_framework, framework
      end

      def success
        ServiceResponse.success(message: _('Framework successfully deleted'))
      end

      def error
        ServiceResponse.error(message: _('Failed to create framework'), payload: framework.errors )
      end
    end
  end
end
