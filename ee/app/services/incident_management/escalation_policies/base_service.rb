# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicies
    class BaseService
      def allowed?
        user&.can?(:admin_incident_management_escalation_policy, project)
      end

      def invalid_schedules?
        params[:rules_attributes]&.any? { |attrs| attrs[:oncall_schedule]&.project != project }
      end

      def duplicate_rules?
        # TODO ruby check?
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(escalation_policy)
        ServiceResponse.success(payload: { escalation_policy: escalation_policy })
      end

      def error_no_permissions
        error(_('You have insufficient permissions to configure escalation policies for this project'))
      end

      def error_no_rules
        error(_('Escalation policies must have at least one rule'))
      end

      def error_bad_schedules
        error(_('All escalations rules must have a schedule in the same project as the policy'))
      end

      def error_in_save(policy)
        error(policy.errors.full_messages.to_sentence)
      end
    end
  end
end
