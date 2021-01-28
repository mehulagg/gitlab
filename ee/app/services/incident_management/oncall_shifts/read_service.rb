# frozen_string_literal: true

module IncidentManagement
  module OncallShifts
    class ReadService
      MAXIMUM_TIMEFRAME = 1.month

      # @param rotation [IncidentManagement::OncallRotation]
      # @param current_user [User]
      # @param params [Hash<Symbol,Any>]
      # @option params - start_time [Time]
      # @option params - end_time [Time]
      def initialize(rotation, current_user, start_time:, end_time:)
        @rotation = rotation
        @current_user = current_user
        @start_time = start_time
        @end_time = end_time
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_invalid_range unless start_before_end?
        return error_excessive_range unless under_max_timeframe?

        success(
          ::IncidentManagement::OncallShiftGenerator
          .new(rotation)
          .for_timeframe(starts_at: start_time, ends_at: end_time)
        )
      end

      private

      attr_reader :rotation, :current_user, :start_time, :end_time

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(rotation.project)
      end

      def allowed?
        Ability.allowed?(current_user, :read_incident_management_oncall_schedule, rotation)
      end

      def start_before_end?
        start_time < end_time
      end

      def under_max_timeframe?
        end_time.to_date <= start_time.to_date + MAXIMUM_TIMEFRAME
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(shifts)
        ServiceResponse.success(payload: { shifts: shifts })
      end

      def error_no_permissions
        error(_('You have insufficient permissions to view shifts for this rotation'))
      end

      def error_no_license
        error(_('Your license does not support on-call rotations'))
      end

      def error_invalid_range
        error(_('`start_time` should precede `end_time`'))
      end

      def error_excessive_range
        error(_('`end_time` should not exceed one month after `start_time`'))
      end
    end
  end
end
