# frozen_string_literal: true

module IncidentManagement
  class OncallShiftGenerator
    # @param rotation [IncidentManagement::OncallRotation]
    def initialize(rotation)
      @rotation = rotation
    end

    # @param starts_at [ActiveSupport::TimeWithZone]
    # @param ends_at [ActiveSupport::TimeWithZone]
    def for_timeframe(starts_at:, ends_at:)
      starts_at = [starts_at, rotation.starts_at].max

      return [] unless starts_at < ends_at
      return [] unless rotation.participants.any?

      # The first shift within the timeframe may begin before
      # the timeframe. We want to begin generating shifts
      # based on the actual start time of the shift.
      shift_starts_at = shift_start_time(starts_at)
      shift_count = elapsed_whole_shifts(starts_at)
      shifts = []

      while shift_starts_at < ends_at
        shifts << shift_for(shift_count, shift_starts_at)
        shift_starts_at += shift_duration
        shift_count += 1
      end

      shifts
    end

    # @param timestamp [ActiveSupport::TimeWithZone]
    def for_timestamp(timestamp)
      return if timestamp < rotation.starts_at
      return unless rotation.participants.any?

      shift_starts_at = shift_start_time(timestamp)
      shift_count = elapsed_whole_shifts(timestamp)

      shift_for(shift_count, shift_starts_at)
    end

    private

    attr_reader :rotation
    delegate :shift_duration, to: :rotation

    # Starting time of a shift which covers the timestamp.
    # @return [ActiveSupport::TimeWithZone]
    def shift_start_time(timestamp)
      rotation.starts_at + (elapsed_whole_shifts(timestamp) * shift_duration)
    end

    # Total complete shifts passed between rotation start
    # time and the provided timestamp.
    # @return [Integer]
    def elapsed_whole_shifts(timestamp)
      # Uses #round to account for floating point inconsistencies.
      (elapsed_duration(timestamp) / shift_duration).round(5).floor
    end

    # Time passed between the start time of the rotation and
    # the provided timestamp.
    # @return [ActiveSupport::Duration]
    def elapsed_duration(timestamp)
      timestamp - rotation.starts_at
    end

    # Position in an array of participants based on the
    # number of shifts which have elasped for the rotation.
    # @return [Integer]
    def participant_rank(elapsed_shifts_count)
      elapsed_shifts_count % participants.length
    end

    # Returns an UNSAVED shift, as this shift won't necessarily
    # be persisted.
    # @return [IncidentManagement::OncallShift]
    def shift_for(shift_count, shift_starts_at)
      IncidentManagement::OncallShift.new(
        rotation: rotation,
        participant: participants[participant_rank(shift_count)],
        starts_at: shift_starts_at,
        ends_at: shift_starts_at + shift_duration
      )
    end

    def participants
      @participants ||= rotation.participants.color_order
    end
  end
end
