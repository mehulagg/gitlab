# frozen_string_literal: true

module EE
  module Ci
    module ChangeVariablesService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super.tap do |result|
          log_audit_events if result
        end
      end

      private

      def log_audit_events
        params[:variables_attributes].each do |variable_params|
          action = variable_action(variable_params)
          target = target_variable(action, variable_params)

          ::Ci::AuditVariableChangeService.new(
            container: container,
            current_user: current_user,
            params: { action: action, variable: target }
          ).execute
        end
      end

      def find_variable_by_id(target_id)
        container.variables.find { |variable| variable.id.to_s == target_id.to_s }
      end

      def find_variable_by_key(target_key)
        container.variables.find { |variable| variable.key == target_key }
      end

      def variable_class
        container.class.reflect_on_association(:variables).klass
      end

      def variable_action(variable_params)
        if variable_params[:_destroy]
          :destroy
        elsif variable_params[:id].nil?
          :create
        else
          :update
        end
      end

      def target_variable(action, variable_params)
        case action
        when :create
          find_variable_by_key(variable_params[:key])
        when :update
          find_variable_by_id(variable_params[:id])
        when :destroy
          variable_class.new(variable_params.except(:_destroy))
        end
      end
    end
  end
end
