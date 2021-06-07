# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicies
    class BaseService
      def allowed?
        user&.can?(:admin_incident_management_escalation_policy, project)
      end

      def available?
        ::Gitlab::IncidentManagement.escalation_policies_available?(project)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(escalation_policy)
        ServiceResponse.success(payload: { escalation_policy: escalation_policy })
      end

      def error_no_license
        error(_('Escalation policies are not supported for this project'))
      end
    end
  end
end
