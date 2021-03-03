# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class BaseService
      def allowed?
        user&.can?(:admin_incident_management_oncall_schedule, project)
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(project)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(oncall_rotation)
        ServiceResponse.success(payload: { oncall_rotation: oncall_rotation })
      end

      def error_no_license
        error(_('Your license does not support on-call rotations'))
      end
    end
  end
end
