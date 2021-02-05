# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class DestroyService
      # @param oncall_schedule [IncidentManagement::OncallRotation]
      # @param user [User]
      def initialize(oncall_rotation, user)
        @oncall_rotation = oncall_rotation
        @user = user
        @project = oncall_rotation.project
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if oncall_rotation.destroy
          success
        else
          error(oncall_rotation.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :oncall_rotation, :user, :project

      def allowed?
        user&.can?(:admin_incident_management_oncall_schedule, project)
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(project)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success
        ServiceResponse.success(payload: { oncall_rotation: oncall_rotation })
      end

      def error_no_permissions
        error(_('You have insufficient permissions to remove an on-call rotation from this project'))
      end

      def error_no_license
        error(_('Your license does not support on-call rotations'))
      end
    end
  end
end
