# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class UpdateService < BaseService
      attr_reader :framework, :current_user, :params

      def initialize(framework:, current_user:, params:)
        @framework = framework
        @current_user = current_user
        @params = params
      end

      def execute
        return error unless permitted?

        framework.update(params) ? success : error
      end

      def success
        ServiceResponse.success(payload: { framework: framework })
      end

      def error
        ServiceResponse.error(message: _('Failed to update framework'), payload: framework.errors )
      end

      private

      def permitted?
        can? current_user, :manage_compliance_framework, framework
      end
    end
  end
end
