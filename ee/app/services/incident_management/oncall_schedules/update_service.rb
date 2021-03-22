# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class UpdateService < OncallSchedules::BaseService
      # @param oncall_schedule [IncidentManagement::OncallSchedule]
      # @param user [User]
      # @param params [Hash]
      def initialize(oncall_schedule, user, params)
        @oncall_schedule = oncall_schedule
        @original_schedule_timezone = oncall_schedule&.timezone
        @oncall_rotations = oncall_schedule&.rotations
        @user = user
        @params = params
        @project = oncall_schedule.project
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if oncall_schedule.update(params)
          update_rotation_active_periods
          success(oncall_schedule)
        else
          error(oncall_schedule.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :oncall_schedule, :original_schedule_timezone, :oncall_rotations, :user, :params, :project

      def update_rotation_active_periods
        oncall_schedule.rotations.select(&:has_shift_active_period?).each do |rotation|
          rotation.update!(
            active_period_start: new_rotation_active_period(rotation.active_period_start).strftime('%H:%M'),
            active_period_end: new_rotation_active_period(rotation.active_period_end).strftime('%H:%M')
          )
        end

        # TODO do we need to handle run update rotation job?
        # Should the above be moved to update rotation job?
      end

      def new_rotation_active_period(time_string)
        time_string.in_time_zone(original_schedule_timezone).in_time_zone(oncall_schedule.timezone)
      end

      def error_no_permissions
        error(_('You have insufficient permissions to update an on-call schedule for this project'))
      end
    end
  end
end
