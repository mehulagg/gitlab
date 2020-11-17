# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    class CreateService < BaseService
      def initialize(namespace:, params:, current_user:)
        @namespace = namespace
        @params = params
        @current_user = current_user
      end

      def execute
        return ServiceResponse.error(message: _('Feature not available')) unless permitted?

        @framework = ComplianceManagement::Framework.new(
          namespace: @namespace,
          name: @params[:name],
          description: @params[:description],
          color: @params[:color]
        )

        @framework.save ? success : error
      end

      private

      def permitted?
        License.feature_available?(:custom_compliance_frameworks) && @namespace.owner == @current_user
      end

      def success
        ServiceResponse.success(payload: { framework: @framework })
      end

      def error
        ServiceResponse.error(message: _('Failed to create framework'), payload: @framework.errors )
      end
    end
  end
end
