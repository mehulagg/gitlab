# frozen_string_literal: true

module Ci
  class AuditVariableChangeService < ::BaseContainerService
    include ::Audit::Changes

    def execute
      return unless container.feature_available?(:audit_events)

      case params[:action]
      when :create, :destroy
        log_audit_event(params[:action], params[:variable])
      when :update
        audit_changes(
          :protected,
          as: 'variable protection', entity: container,
          model: params[:variable], target_details: params[:variable].key
        )
      end
    end

    private

    def log_audit_event(action, variable)
      case variable.class.to_s
      when ::Ci::Variable.to_s
        ::AuditEventService.new(
          current_user,
          container,
          action: action
        ).for_project_variable(variable.key).security_event
      when ::Ci::GroupVariable.to_s
        ::AuditEventService.new(
          current_user,
          container,
          action: action
        ).for_group_variable(variable.key).security_event
      end
    end
  end
end
