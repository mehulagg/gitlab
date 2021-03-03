# frozen_string_literal: true

module IncidentManagement
  module OncallShifts
    # Used to gracefully edit rotation parameters. When a
    # rotation is updated, any currently running shift will
    # be cut short and a new shift will be saved.
    class ResetRotationService
      include Gitlab::Utils::StrongMemoize

      # @param rotation [IncidentManagement::OncallRotation]
      # @param current_user [User]
      def initialize(rotation, current_user)
        @rotation = rotation
        @current_user = current_user
        @reset_time = rotation.updated_at
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_in_save(existing_shift) unless existing_shift_ended?
        return error_in_save(new_shift) unless new_shift_started?

        ServiceResponse.success
      end

      private

      attr_reader :rotation, :current_user, :reset_time

      def existing_shift_ended?
        !existing_shift || existing_shift.update(ends_at: reset_time)
      end

      def new_shift_started?
        !new_shift || new_shift.update(starts_at: reset_time)
      end

      def existing_shift
        strong_memoize(:existing_shift) do
          rotation.shifts.for_timestamp(reset_time)
        end
      end

      def new_shift
        strong_memoize(:new_shift) do
          IncidentManagement::OncallShiftGenerator.new(rotation).for_timestamp(reset_time)
        end
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(rotation.project)
      end

      def allowed?
        Ability.allowed?(current_user, :read_incident_management_oncall_schedule, rotation)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def error_no_permissions
        error(_('You have insufficient permissions to view shifts for this rotation'))
      end

      def error_no_license
        error(_('Your license does not support on-call rotations'))
      end

      def error_in_save(shift)
        error(shift.errors.full_messages.to_sentence)
      end
    end
  end
end
