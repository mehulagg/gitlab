# frozen_string_literal: true

module Types
  module IncidentManagement
    class OncallShiftType < BaseObject
      graphql_name 'OncallShiftType'
      description 'A block of time for which a user is on-call.'

      authorize :read_incident_management_oncall_schedule

      field :participant,
            ::Types::IncidentManagement::OncallParticipantType,
            null: true,
            description: 'Participant assigned to the on-call slot.'

      field :starts_at,
            Types::TimeType,
            null: true,
            description: 'Start time of the on-call shift.'

      field :ends_at,
            Types::TimeType,
            null: true,
            description: 'End time of the on-call shift.'
    end
  end
end
