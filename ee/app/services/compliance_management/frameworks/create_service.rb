# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class CreateService < BaseService
      include ::ComplianceManagement::Frameworks

      attr_reader :namespace, :params, :current_user, :framework

      def initialize(namespace:, params:, current_user:)
        @namespace = namespace&.root_ancestor
        @params = params
        @current_user = current_user
        @framework = ComplianceManagement::Framework.new
      end

      def execute
        framework.assign_attributes(
          namespace: namespace,
          name: params[:name],
          description: params[:description],
          color: params[:color],
          pipeline_configuration_full_path: params[:pipeline_configuration_full_path]
        )

        return ServiceResponse.error(message: 'Not permitted to create framework') unless permitted?
        return ServiceResponse.error(message: 'Pipeline configuration full path feature is not available') unless compliance_pipeline_configuration_available?

        framework.save ? success : error
      end

      private

      def permitted?
        can? current_user, :manage_compliance_framework, framework
      end

      def success
        ServiceResponse.success(payload: { framework: framework })
      end

      def error
        ServiceResponse.error(message: _('Failed to create framework'), payload: framework.errors )
      end
    end
  end
end
