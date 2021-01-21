# frozen_string_literal: true

module IncidentManagement
  class OncallParticipantsFinder
    include Gitlab::Utils::StrongMemoize

    # @param rotation [Project]
    # @param params [Hash]
    # @option params oncall_at [ActiveSupport::TimeWithZone]
    #                       Limits participants to only those
    #                       on-call at the specified time.
    # @return [IncidentManagement::OncallParticipant::ActiveRecord_Relation]
    def initialize(project, params = {})
      @project = project
      @params = params
    end

    def execute
      return IncidentManagement::OncallParticipant.none unless Gitlab::IncidentManagement.oncall_schedules_available?(project)
      return active_oncall_participants if params[:oncall_at]

      all_participants
    end

    private

    attr_reader :project, :params

    def all_participants
      project.incident_management_oncall_participants
    end

    # Reads shifts from DB. This is the historical record,
    # and we should adhere to it if available. If rotations
    # are missing persited shifts for some reason, fallback
    # to a generated shift. It may also be possible no one
    # is on call for that rotation.
    def active_oncall_participants
      return IncidentManagement::OncallParticipant.none unless active_oncall_participant_ids.present?

      IncidentManagement::OncallParticipant.id_in(active_oncall_participant_ids)
    end

    def active_oncall_participant_ids
      strong_memoize(:actively_oncall_participant_ids) do
        Array(persisted_shifts).concat(generated_shifts).map(&:participant_id)
      end
    end

    def rotations
      strong_memoize(:rotations) do
        project.incident_management_oncall_rotations
      end
    end

    def persisted_shifts
      strong_memoize(:persisted_shifts) do
        IncidentManagement::OncallShift
          .for_rotation(rotations)
          .for_timestamp(params[:oncall_at])
      end
    end

    def rotations_without_persisted_shift
      rotations
        .except_ids(persisted_shifts.map(&:rotation_id))
        .with_shift_generation_associations
    end

    def generated_shifts
      rotations_without_persisted_shift.map do |rotation|
        IncidentManagement::OncallShiftGenerator
          .new(rotation)
          .for_timestamp(params[:oncall_at])
      end.compact
    end
  end
end
