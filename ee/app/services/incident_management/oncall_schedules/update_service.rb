# frozen_string_literal: true

module IncidentManagement
  module OncallSchedules
    class UpdateService < OncallSchedules::BaseService
      # @param oncall_schedule [IncidentManagement::OncallSchedule]
      # @param user [User]
      # @param params [Hash]
      def initialize(oncall_schedule, user, params)
        @oncall_schedule = oncall_schedule
        @original_schedule_timezone = oncall_schedule.timezone
        @user = user
        @params = params
        @project = oncall_schedule.project
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        IncidentManagement::OncallSchedule.transaction do
          oncall_schedule.update!(params)
          update_rotations!
        end

        success(oncall_schedule)
      rescue ActiveRecord::RecordInvalid => e
        error(e.record.errors.full_messages.to_sentence)
      rescue StandardError => e
        error(e.message)
      end

      private

      attr_reader :oncall_schedule, :original_schedule_timezone, :user, :params, :project

      def update_rotations!
        return if same_schedule_timezone?

        update_rotation_active_periods!
      end

      def same_schedule_timezone?
        original_schedule_timezone == oncall_schedule.timezone
      end

      # Converts & updates the active period to the new timezone
      # Ex: 8:00 - 17:00 Europe/Berlin becomes 6:00 - 15:00 UTC
      def update_rotation_active_periods!
        original_schedule_current_time = Time.current.in_time_zone(original_schedule_timezone)

        oncall_schedule.rotations.with_active_period.each do |rotation|
          active_period = rotation.active_period.for_date(original_schedule_current_time)
          new_start_time, new_end_time = active_period.map { |time| time.in_time_zone(oncall_schedule.timezone).strftime('%H:%M') }

          service = IncidentManagement::OncallRotations::EditService.new(
            rotation,
            user,
            {
              active_period_start: new_start_time,
              active_period_end: new_end_time
            }
          )

          response = service.execute

          raise response.message if response.error?
        end
      end

      def error_no_permissions
        error(_('You have insufficient permissions to update an on-call schedule for this project'))
      end
    end
  end
end
