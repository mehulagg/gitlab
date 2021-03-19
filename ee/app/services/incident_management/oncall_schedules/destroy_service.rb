# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class DestroyService < OncallSchedules::BaseService
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
          success(oncall_schedule)
        else
          error(oncall_schedule.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :oncall_schedule, :user, :project

      def error_no_permissions
        error(_('You have insufficient permissions to remove an on-call schedule from this project'))
      end
    end
  end
end
