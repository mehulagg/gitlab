# frozen_string_literal: true

module IncidentManagement
  module OncallShifts
    class ReadService
      # @param rotation [IncidentManagement::OncallRotation]
      # @param current_user [User]
      # @param params [Hash<Symbol,Any>]
      # @option params - starts_at [Time]
      # @option params - ends_at [Time]
      def initialize(rotation, current_user, starts_at:, ends_at:)
        @rotation = rotation
        @current_user = current_user
        @starts_at = starts_at
        @ends_at = ends_at
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        success(
          ::IncidentManagement::OncallShiftGenerator
          .new(rotation)
          .for_timeframe(starts_at: starts_at, ends_at: ends_at)
        )
      end

      private

      attr_reader :rotation, :current_user, :starts_at, :ends_at

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(rotation.project)
      end

      def allowed?
        Ability.allowed?(current_user, :read_incident_management_oncall_schedule, rotation)
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
    end
  end
end
