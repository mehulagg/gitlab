# frozen_string_literal: true

module Types
  module Iterations
    class CadenceType < BaseObject
      graphql_name 'IterationsCadence'
      description 'Represents an iterations cadence'

      authorize :read_iterations_cadence

      field :id, ::Types::GlobalIDType[::Iterations::Cadence], null: false,
        description: 'Global ID of the iterations cadence.'

      field :title, GraphQL::STRING_TYPE, null: false,
        description: 'Title of the iterations cadence.'

      field :duration_in_weeks, GraphQL::INT_TYPE, null: false,
        description: 'Duration in weeks of an iterations under this cadence.'

      field :iterations_in_advance, GraphQL::INT_TYPE, null: false,
        description: 'Iterations in advance to be created when iterations cadence is set to automatic.'

      field :start_date, Types::TimeType, null: true,
        description: 'Timestamp of the iterations cadence start date.'

      field :automatic, GraphQL::BOOLEAN_TYPE, null: true,
        description: 'Automatic flag to set the iterations cadence to automatically generate future iterations.'

      field :active, GraphQL::BOOLEAN_TYPE, null: true,
        description: 'Active flag to activate or deactivate an iterations cadence.'
    end
  end
end
