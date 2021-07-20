# frozen_string_literal: true

module Types
  module Dast
    class ProfileScheduleType < BaseObject
      graphql_name 'DastProfileSchedule'
      description 'Represents DAST Profile Schedules'

      authorize :read_on_demand_scans

      field :active, GraphQL::STRING_TYPE, null: false,
            required: true,
            description: 'The status of a Schedule.',
            calls_gitaly: true # Do we need this?

      field :starts_at, Types::TimeType, null: true,
            required: false
            description: 'Start time of the Schedule.'

      field :repeats,
            ::Types::Dast::RecurringScheduleEnum,
            required: false,
            description: 'Recurring Schedules for a Dast Profile Schedule'
    end
  end
end
