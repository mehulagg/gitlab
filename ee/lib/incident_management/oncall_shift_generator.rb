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
      starts_at = [apply_timezone(starts_at), rotation_starts_at].max
      ends_at = apply_timezone(ends_at)

      return [] unless starts_at < ends_at
      return [] unless rotation.participants.any?

      # The first shift within the timeframe may begin before
      # the timeframe. We want to begin generating shifts
      # based on the actual start time of the shift.
      elapsed_shift_count = elapsed_whole_shifts(starts_at)
      shift_starts_at = shift_start_time(elapsed_shift_count)
      shifts = []

      while shift_starts_at < ends_at
        shifts << shift_for(elapsed_shift_count, shift_starts_at)

        shift_starts_at += shift_duration
        elapsed_shift_count += 1
      end

      shifts
    end

    # @param timestamp [ActiveSupport::TimeWithZone]
    def for_timestamp(timestamp)
      timestamp = apply_timezone(timestamp)

      return if timestamp < rotation_starts_at
      return unless rotation.participants.any?

      elapsed_shift_count = elapsed_whole_shifts(timestamp)
      shift_starts_at = shift_start_time(elapsed_shift_count)

      shift_for(elapsed_shift_count, shift_starts_at)
    end

    private

    attr_reader :rotation
    delegate :shift_duration, to: :rotation

    # Starting time of a shift which covers the timestamp.
    # @return [ActiveSupport::TimeWithZone]
    def shift_start_time(elapsed_shift_count)
      rotation_starts_at + (elapsed_shift_count * shift_duration)
    end

    # Total completed shifts passed between rotation start
    # time and the provided timestamp.
    # @return [Integer]
    def elapsed_whole_shifts(timestamp)
      elapsed_duration = timestamp - rotation_starts_at

      # Rotations in days & weeks must accomodate timezone
      # changes in the shift start time.
      # EX) If we had a 23-hr "day" shift, we still need that
      # to count as a full 24-hr day.
      if !rotation.hours? && timestamp.utc_offset.abs > rotation_starts_at.utc_offset.abs
        elapsed_duration += (timestamp.utc_offset.abs - rotation_starts_at.utc_offset.abs)
      end

      # Uses #round to account for floating point inconsistencies.
      (elapsed_duration / shift_duration).round(5).floor
    end

    # Returns an UNSAVED shift, as this shift won't necessarily
    # be persisted.
    # @return [IncidentManagement::OncallShift]
    def shift_for(elapsed_shift_count, shift_starts_at)
      IncidentManagement::OncallShift.new(
        rotation: rotation,
        participant: participants[participant_rank(elapsed_shift_count)],
        starts_at: shift_starts_at,
        ends_at: shift_starts_at + shift_duration
      )
    end

    # Position in an array of participants based on the
    # number of shifts which have elasped for the rotation.
    # @return [Integer]
    def participant_rank(elapsed_shifts_count)
      elapsed_shifts_count % participants.length
    end

    def participants
      @participants ||= rotation.participants.ordered
    end

    def rotation_starts_at
      @rotaton_starts_at ||= apply_timezone(rotation.starts_at)
    end

    def apply_timezone(timestamp)
      timestamp.in_time_zone(rotation.schedule.timezone)
    end
  end
end
