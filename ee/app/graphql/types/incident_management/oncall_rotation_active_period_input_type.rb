# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallRotationActivePeriodInputType < BaseInputObject
      graphql_name 'OncallRotationActivePeriodInputType'
      description 'Active period time range for on-call rotation'

      argument :start_time, GraphQL::STRING_TYPE,
                required: true,
                description: 'The start of the rotation active period.'

      argument :end_time, GraphQL::STRING_TYPE,
                required: true,
                description: 'The end of the rotation active period.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
