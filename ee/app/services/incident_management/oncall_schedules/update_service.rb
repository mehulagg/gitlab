# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class UpdateService < OncallSchedules::BaseService
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

      def error_no_permissions
        error(_('You have insufficient permissions to update an on-call schedule for this project'))
      end
    end
  end
end
