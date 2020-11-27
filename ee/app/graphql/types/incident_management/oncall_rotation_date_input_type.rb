# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallRotationDateInputType < BaseInputObject
      graphql_name 'OncallRotationDateInputType'
      description 'Date input type for on-call rotation'

      argument :date, GraphQL::STRING_TYPE,
                required: true,
                description: 'The date component of the date in YYYY-MM-DD format'

      argument :time, GraphQL::STRING_TYPE,
                required: true,
                description: 'The time component of the date in 24hr HH:MM format'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
