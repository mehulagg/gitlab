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
        return ServiceResponse.error(message: 'Not permitted to update pipeline_configuration_full_path') unless force_includes_available?

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

      def force_includes_available?
        return true unless params[:pipeline_configuration_full_path].present?

        can? current_user, :manage_compliance_force_includes, framework
      end
    end
  end
end
