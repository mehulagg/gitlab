# frozen_string_literal: true

module Types
  module IncidentManagement
    class OncallRotationType < BaseObject
      graphql_name 'IncidentManagementOncallRotation'
      description 'Describes an incident management on-call rotation'

      authorize :read_incident_management_oncall_schedule

      field :id,
            Types::GlobalIDType[::IncidentManagement::OncallRotation],
            null: false,
            description: 'ID of the on-call rotation.'

      field :name,
            GraphQL::STRING_TYPE,
            null: false,
            description: 'Name of the on-call rotation.'

      field :starts_at,
            Types::TimeType,
            null: true,
            description: 'Start date of the on-call rotation.'

      field :length,
            GraphQL::INT_TYPE,
            null: true,
            description: 'Length of the on-call schedule, in the units specified by lengthUnit.'

      field :length_unit,
            Types::IncidentManagement::OncallRotationLengthUnitEnum,
            null: true,
            description: 'Unit of the on-call rotation length.'

      field :participants,
            ::Types::IncidentManagement::OncallParticipantType.connection_type,
            null: true,
            description: 'Participants of the on-call rotation.'

      field :shifts,
            ::Types::IncidentManagement::OncallShiftType.connection_type,
            null: true,
            description: 'Blocks of time for which a participant is on-call within a given timeframe. Timeframe cannot exceed one month.',
            resolver: ::Resolvers::IncidentManagement::OncallShiftsResolver
    end
  end
end
