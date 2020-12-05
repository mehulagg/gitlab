# frozen_string_literal: true

module IncidentManagement
  module OncallShiftGenerator
    def initialize(rotation, starts_at:, ends_at:)
      @rotation = rotation
      @starts_at = [starts_at, rotation.starts_at].max
      @ends_at = ends_at
    end

    def execute
      return [] unless starts_at < ends_at

      # The first shift within the timeframe may begin before
      # the timeframe. We want to begin generating shifts
      # based on the actual start time of the shift.
      shift_starts_at = initial_shift_starts_at
      shift_count = elapsed_whole_shifts
      shifts = []

      while shift_starts_at < ends_at
        shifts << IncidentManagement::OncallShift.new(
          user: participants[participant_idx(shift_count)],
          starts_at: shift_starts_at,
          ends_at: shift_starts_at + shift_duration
        )

        shift_starts_at += shift_duration
        shift_count += 1
      end

      shifts
    end

    private

    attr_reader :rotation, :start_at, :end_time
    delegate :participants, :shift_duration, to: :rotation

    def initial_shift_starts_at
      rotation.starts_at + (elapsed_whole_shifts * shift_duration)
    end

    def elapsed_whole_shifts
      (elapsed_duration / shift_duration).round(5).floor
    end

    def elapsed_duration
      starts_at - rotation.starts_at
    end

    def participant_idx(elapsed_shifts_count)
      elapsed_shifts_count % participants.length
    end
  end
end
