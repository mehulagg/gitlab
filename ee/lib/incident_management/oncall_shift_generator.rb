# frozen_string_literal: true

module IncidentManagement
  class OncallShiftGenerator
    # @param rotation [IncidentManagement::OncallRotation]
    # @param starts_at [DateTime]
    # @param ends_at [DateTime]
    def initialize(rotation, starts_at:, ends_at:)
      @rotation = rotation
      @starts_at = [starts_at, rotation.starts_at].max
      @ends_at = ends_at
    end

    # Generates shifts for the rotation and timeframe
    # @return [Array<IncidentManagement::OncallShift>]
    def execute
      return [] unless starts_at < ends_at
      return [] unless rotation.participants.any?

      # The first shift within the timeframe may begin before
      # the timeframe. We want to begin generating shifts
      # based on the actual start time of the shift.
      shift_starts_at = initial_shift_starts_at
      shift_count = elapsed_whole_shifts
      shifts = []

      while shift_starts_at < ends_at
        shifts << shift_for(shift_count, shift_starts_at)
        shift_starts_at += shift_duration
        shift_count += 1
      end

      shifts
    end

    private

    attr_reader :rotation, :starts_at, :ends_at
    delegate :shift_duration, to: :rotation

    # Start time of the first shift represented in the
    # time range arguments. May be before starts_at.
    def initial_shift_starts_at
      rotation.starts_at + (elapsed_whole_shifts * shift_duration)
    end

    # Total complete shifts passed between rotation start
    # time and start time of the time range arguments.
    def elapsed_whole_shifts
      (elapsed_duration / shift_duration).round(5).floor
    end

    # Time passed between the start time of the rotation and
    # the start time of the time range arguments. If rotation
    # starts after the initial time range argument, this
    # will be 0.
    def elapsed_duration
      starts_at - rotation.starts_at
    end

    # Position in an array of participants based on the
    # number of shifts which have elasped for the rotation.
    def participant_idx(elapsed_shifts_count)
      elapsed_shifts_count % participants.length
    end

    # Returns an UNSAVED shift, as this shift won't necessarily
    # be persisted.
    # @return [IncidentManagement::OncallShift]
    def shift_for(shift_count, shift_starts_at)
      IncidentManagement::OncallShift.new(
        rotation: rotation,
        participant: participants[participant_idx(shift_count)],
        starts_at: shift_starts_at,
        ends_at: shift_starts_at + shift_duration
      )
    end

    def participants
      @participants ||= rotation.participants.color_order
    end
  end
end
