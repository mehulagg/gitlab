# frozen_string_literal: true

module IncidentManagement
  class OncallShiftGenerator
    # @param rotation [IncidentManagement::OncallRotation]
    def initialize(rotation)
      @rotation = rotation
    end

    # Generates an array of shifts which cover the provided time range.
    #
    # @param starts_at [ActiveSupport::TimeWithZone]
    # @param ends_at [ActiveSupport::TimeWithZone]
    # @return [IncidentManagement::OncallShift]
    def for_timeframe(starts_at:, ends_at:)
      starts_at = [apply_timezone(starts_at), rotation_starts_at].max
      ends_at = apply_timezone(ends_at)

      return [] unless starts_at < ends_at
      return [] unless rotation.participants.any?

      # The first shift within the timeframe may begin before
      # the timeframe. We want to begin generating shifts
      # based on the actual start time of the shift cycle.
      elapsed_shift_cycle_count = elapsed_whole_shift_cycles(starts_at)
      shift_cycle_starts_at = shift_cycle_start_time(elapsed_shift_cycle_count)
      shifts = []

      while shift_cycle_starts_at < ends_at
        new_shifts = Array(shift_cycle_for(elapsed_shift_cycle_count, shift_cycle_starts_at))
        new_shifts.reject! { |shift| shift.ends_at < starts_at } if shift_cycle_starts_at < starts_at
        new_shifts.reject! { |shift| shift.starts_at > ends_at } if (shift_cycle_starts_at + shift_cycle_duration) > ends_at

        shifts.concat(new_shifts)

        shift_cycle_starts_at += shift_cycle_duration
        elapsed_shift_cycle_count += 1
      end

      shifts
    end

    # Generates a single shift during which the timestamp occurs.
    #
    # @param timestamp [ActiveSupport::TimeWithZone]
    # @return IncidentManagement::OncallShift
    def for_timestamp(timestamp)
      timestamp = apply_timezone(timestamp)

      return if timestamp < rotation_starts_at
      return unless rotation.participants.any?

      elapsed_shift_count = elapsed_whole_shift_cycles(timestamp)
      shift_cycle_starts_at = shift_cycle_start_time(elapsed_shift_count)

      participant = participants[participant_rank(elapsed_shift_count)]

      shift_for(participant, shift_cycle_starts_at, shift_cycle_starts_at + shift_cycle_duration)
    end

    private

    attr_reader :rotation
    delegate :shift_cycle_duration, to: :rotation

    # Starting time of a shift which covers the timestamp.
    # @return [ActiveSupport::TimeWithZone]
    def shift_cycle_start_time(elapsed_shift_count)
      rotation_starts_at + (elapsed_shift_count * shift_cycle_duration)
    end

    # Total completed shifts passed between rotation start
    # time and the provided timestamp.
    # @return [Integer]
    def elapsed_whole_shift_cycles(timestamp)
      elapsed_duration = timestamp - rotation_starts_at

      unless rotation.hours?
        # Changing timezones (like during daylight savings) can
        # cause a "day" to have a duration other than 24 hours ("weeks" too).
        # Since elapsed_duration is in seconds, we need
        # account for this variable day/week length to
        # determine how many actual shifts have elapsed.
        #
        # Ex) If a location with daylight savings sets their
        # clocks forward an hour, a 1-day shift will last for
        # 23 hours if it occurs over that transition.
        #
        # If we want to generate a shift which occurs 1 week
        # after the timezone change, the real elapsed seconds
        # will equal 1 week minus an hour.
        #
        # Seconds per average week: 2 * 7 * 24 * 60 * 60 = 1209600
        # Seconds in zone-shifted week: 1209600 - (60 * 60) = 1206000
        #
        # If we count in seconds, minutes, or hours, these are different durations.
        # If we count in "days" or "weeks", these durations are equivalent.
        #
        # To determine how many effective days or weeks
        # a duration (in seconds) was, we need to normalize
        # the duration to fit the definition of a 24-hour day.
        # We can do this by diffing the UTC-offsets between the
        # start time of the rotation and the relevant timestamp.
        # This should account for different hemispheres,
        # offsets changes other an 1 hour, and one-off timezone changes.
        elapsed_duration += timestamp.utc_offset - rotation_starts_at.utc_offset
      end

      # Uses #round to account for floating point inconsistencies.
      (elapsed_duration / shift_cycle_duration).round(5).floor
    end

    def shift_cycle_for(elapsed_shift_cycle_count, shift_cycle_starts_at)
      participant = participants[participant_rank(elapsed_shift_cycle_count)]

      if !rotation.hours? && rotation.has_shift_intervals?
        # the number of shifts we expect to be included in the
        # shift_cycle. 1.week is the same as 7.days.
        expected_shift_count = rotation.weeks? ? (7 * rotation.length) : rotation.length
        (0..expected_shift_count - 1).map do |shift_count|
          # we know the start/end time of the intervals,
          # so the date is dependent on the cycle start time
          # and how many days have elapsed in the cycle.
          # EX) shift_cycle_starts_at = Monday @ 8am
          #     interval_starts_at = 8am
          #     interval_ends_at = 5pm
          #     expected_shift_count = 14          -> pretend it's a 2-week rotation
          #     shift_count = 2                    -> we're calculating the shift for the 3rd day
          # starts_at = Monday 00:00:00 + 8.hours + 2.days => Thursday 08:00:00
          starts_at = shift_cycle_starts_at.beginning_of_day + rotation.interval_times[:start].seconds_since_midnight + shift_count.days
          ends_at = shift_cycle_starts_at.beginning_of_day + rotation.interval_times[:end].seconds_since_midnight + shift_count.days

          shift_for(participant, starts_at, ends_at)
        end
      else
        # This is the normal shift start/end times
        shift_for(participant, shift_cycle_starts_at, shift_cycle_starts_at + shift_cycle_duration)
      end
    end

    # Returns an UNSAVED shift, as this shift won't necessarily
    # be persisted.
    # @return [IncidentManagement::OncallShift]
    def shift_for(participant, starts_at, ends_at)
      IncidentManagement::OncallShift.new(
        rotation: rotation,
        participant: participant,
        starts_at: starts_at,
        ends_at: ends_at
      )
    end

    # Position in an array of participants based on the
    # number of shifts which have elasped for the rotation.
    # @return [Integer]
    def participant_rank(elapsed_shifts_count)
      elapsed_shifts_count % participants.length
    end

    def participants
      @participants ||= rotation.participants
    end

    def rotation_starts_at
      @rotation_starts_at ||= apply_timezone(rotation.starts_at)
    end

    def apply_timezone(timestamp)
      timestamp.in_time_zone(rotation.schedule.timezone)
    end
  end
end
