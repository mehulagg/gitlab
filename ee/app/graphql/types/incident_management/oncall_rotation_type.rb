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
            description: 'ID of the on-call rotation'

      field :name,
            GraphQL::STRING_TYPE,
            null: false,
            description: 'Name of the on-call rotation'

      field :starts_at,
            Types::TimeType,
            null: true,
            description: 'Start date of the on-call rotation'

      field :length,
            GraphQL::INT_TYPE,
            null: true,
            description: 'Time zone of the on-call schedule'

      field :length_unit,
            Types::IncidentManagement::OncallRotationLengthUnitEnum,
            null: true,
            description: 'Unit of the on-call rotation length'

      field :participants,
            ::Types::IncidentManagement::OncallUserType.connection_type,
            null: true,
            description: 'Participants of the on-call rotation'

      def participants
        object.oncall_participants
      end
    end
  end
end
