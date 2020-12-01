# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class DestroyService
      # @param oncall_schedule [IncidentManagement::OncallSchedule]
      # @param user [User]
      def initialize(oncall_schedule, user)
        @oncall_schedule = oncall_schedule
        @user = user
        @project = oncall_schedule.project
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if oncall_schedule.destroy
          success
        else
          error(oncall_schedule.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :oncall_schedule, :user, :project

      def allowed?
        user&.can?(:admin_incident_management_oncall_schedule, project)
      end

      def available?
        Feature.enabled?(:oncall_schedules_mvc, project) &&
          project.feature_available?(:oncall_schedules)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success
        ServiceResponse.success(payload: { oncall_schedule: oncall_schedule })
      end

      def error_no_permissions
        error(_('You have insufficient permissions to remove an on-call schedule from this project'))
      end

      def error_no_license
        error(_('Your license does not support on-call schedules'))
      end
    end
  end
end
