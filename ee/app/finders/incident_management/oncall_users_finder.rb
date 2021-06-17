# frozen_string_literal: true

module IncidentManagement
  # Returns users who are oncall by reading shifts from the DB.
  # The DB is the historical record, so we should adhere to it
  # when it is available. If rotations are missing persited
  # shifts for some reason, we'll fallback to a generated shift.
  # It may also be possible that no one is on call for a rotation.
  class OncallUsersFinder
    include Gitlab::Utils::StrongMemoize

    # @param project [Project]
    # @option oncall_at [ActiveSupport::TimeWithZone]
    #                   Limits users to only those
    #                   on-call at the specified time.
    # @option schedule [IncidentManagement::OncallSchedule]
    #                   Limits the users to rotations within a
    #                   specific schedule
    def initialize(project, oncall_at: Time.current, schedule: nil)
      @project = project
      @oncall_at = oncall_at
      @schedule = schedule
    end

    # @return [User::ActiveRecord_Relation]
    def execute
      return User.none unless Gitlab::IncidentManagement.oncall_schedules_available?(project)
      return User.none unless user_ids.present?

      User.id_in(user_ids)
    end

    private

    attr_reader :project, :oncall_at, :schedule

    def user_ids
      strong_memoize(:user_ids) do
        user_ids_for_persisted_shifts.concat(user_ids_for_predicted_shifts).uniq
      end
    end

    def user_ids_for_persisted_shifts
      ids_for_persisted_shifts.flat_map(&:last)
    end

    def rotation_ids_for_persisted_shifts
      ids_for_persisted_shifts.flat_map(&:first)
    end

    def rotations
      strong_memoize(:rotations) do
        schedule ? schedule.rotations : project.incident_management_oncall_rotations
      end
    end

    # @return [Array<[rotation_id, user_id]>]
    # @example - [ [1, 16], [2, 200] ]
    def ids_for_persisted_shifts
      strong_memoize(:ids_for_persisted_shifts) do
        rotations
          .merge(IncidentManagement::OncallShift.for_timestamp(oncall_at))
          .pluck_id_and_user_id
      end
    end

    def user_ids_for_predicted_shifts
      rotations_without_persisted_shifts.map do |rotation|
        next unless shift = IncidentManagement::OncallShiftGenerator.new(rotation).for_timestamp(oncall_at)

        shift.participant.user_id
      end
    end

    def rotations_without_persisted_shifts
      rotations
        .except_ids(rotation_ids_for_persisted_shifts)
        .with_shift_generation_associations
    end
  end
end
