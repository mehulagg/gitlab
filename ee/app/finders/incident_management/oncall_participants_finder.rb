# frozen_string_literal: true

module IncidentManagement
  class OncallParticipantsFinder
    include Gitlab::Utils::StrongMemoize

    # @param rotation [Project]
    # @param params [Hash]
    # @option params is_oncall [Boolean] limits participants to
    #                       only those currently on call
    def initialize(project, params = {})
      @project = project
      @params = params
      @schedules = project.incident_management_oncall_schedules
    end

    def execute
      return IncidentManagement::OncallParticipant.none unless Gitlab::IncidentManagement.oncall_schedules_available?(project)

      participants = params[:is_oncall] ? participants_currently_oncall : all_participants

      IncidentManagement::OncallParticipant.id_in(participants.map(&:id))
    end

    private

    attr_reader :project, :params, :schedules

    def all_participants
      schedules.includes(:participants).flat_map(&:participants)
    end

    # Reads current shifts from DB. This is the historical
    # record and we should adhere to it if available.
    # If rotations are missing persited shifts for some
    # reason, fallback to a generated shift. It may be
    # possible no one is on call for that rotation.
    def participants_currently_oncall
      (known_current_shifts + supplemental_shifts).map(&:participant)
    end

    def rotations
      @rotations ||= schedules.includes(rotations: [:schedule, :participants]).flat_map(&:rotations)
    end

    def timestamp
      @timestamp ||= Time.current
    end

    def known_current_shifts
      strong_memoize(:known_current_shifts) do
        IncidentManagement::OncallShift
          .includes(:participant, :rotation)
          .for_rotation(rotations)
          .for_timestamp(timestamp)
      end
    end

    def rotations_without_current_shift
      rotations - known_current_shifts.map(&:rotation)
    end

    def supplemental_shifts
      rotations_without_current_shift.map do |rotation|
        IncidentManagement::OncallShiftGenerator
          .new(rotation)
          .for_timestamp(timestamp)
      end.compact
    end
  end
end
