# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class CreateService < BaseService
      attr_reader :namespace, :params, :current_user, :framework

      def initialize(namespace:, params:, current_user:)
        @namespace = namespace.root_ancestor
        @params = params
        @current_user = current_user
        @framework = ComplianceManagement::Framework.new
      end

      def execute
        return ServiceResponse.error(message: _('Feature not available')) unless permitted?

        framework.assign_attributes(
          namespace: namespace,
          name: params[:name],
          description: params[:description],
          color: params[:color]
        )

        framework.save ? success : error
      end

      private

      def permitted?
        can?(current_user, :create_custom_compliance_frameworks, namespace)
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
