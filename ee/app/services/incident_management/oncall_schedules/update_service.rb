# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class UpdateService
      # @param oncall_schedule [IncidentManagement::OncallSchedule]
      # @param user [User]
      # @param params [Hash]
      def initialize(oncall_schedule, user, params)
        @oncall_schedule = oncall_schedule
        @user = user
        @params = params
        @project = oncall_schedule.project
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if oncall_schedule.update(params)
          success(oncall_schedule)
        else
          error(oncall_schedule.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :oncall_schedule, :user, :params, :project

      def allowed?
        user&.can?(:admin_incident_management_oncall_schedule, project)
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(project)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(oncall_schedule)
        ServiceResponse.success(payload: { oncall_schedule: oncall_schedule })
      end

      def error_no_permissions
        error(_('You have insufficient permissions to update an on-call schedule for this project'))
      end

      def error_no_license
        error(_('Your license does not support on-call schedules'))
      end
    end
  end
end
