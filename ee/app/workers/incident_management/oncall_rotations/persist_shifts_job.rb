# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class PersistShiftsJob
      include ApplicationWorker

      idempotent!
      feature_category :incident_management

      START_DATE_OFFSET = 6.months

      def perform(rotation_id)
        # For dates up to now (6 months - NOW)
        # Check if any shifts are un-persisted
        # Run generate job and persist them

        rotation = ::IncidentManagement::OncallRotation.find_by_id(rotation_id)

        return unless rotation

        starts_at = START_DATE_OFFSET.ago
        ends_at = Time.current

        generated_shifts = ::IncidentManagement::OncallShiftGenerator.new(
          rotation,
          starts_at: starts_at,
          ends_at: ends_at
        ).execute

        existing_shifts = rotation.shifts.for_timeframe(starts_at, ends_at)

        shifts_to_persist = exlcude_persited_shifts(generated_shifts, existing_shifts)

        shifts_to_persist.each(&:save!)
      end

      private

      def exlcude_persited_shifts(generated_shifts)
        # TODO find a better way
        generated_shifts.reject(&:invalid?)
      end
    end
  end
end
