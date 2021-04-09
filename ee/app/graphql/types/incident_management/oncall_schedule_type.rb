# frozen_string_literal: true

module Types
  module IncidentManagement
    class OncallScheduleType < BaseObject
      graphql_name 'IncidentManagementOncallSchedule'
      description 'Describes an incident management on-call schedule'

      authorize :read_incident_management_oncall_schedule

      field :iid,
            GraphQL::ID_TYPE,
            null: true,
            description: 'Internal ID of the on-call schedule.'

      field :name,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Name of the on-call schedule.'

      field :description,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Description of the on-call schedule.'

      field :timezone,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Time zone of the on-call schedule.'

      field :rotations,
            OncallRotationType.connection_type,
            null: true,
            description: 'On-call rotations for the on-call schedule.'
    end
  end
end
