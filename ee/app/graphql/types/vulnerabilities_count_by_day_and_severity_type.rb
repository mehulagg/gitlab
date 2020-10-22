# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class VulnerabilitiesCountByDayAndSeverityType < BaseObject
    graphql_name 'VulnerabilitiesCountByDayAndSeverity'
    description 'Represents the number of vulnerabilities for a particular severity on a particular day'

    field :count, GraphQL::INT_TYPE, null: true,
          description: 'Number of vulnerabilities'

    field :day, GraphQL::Types::ISO8601Date, null: true,
          description: 'Date for the count'

    field :severity, VulnerabilitySeverityEnum, null: true,
          description: 'Severity of the counted vulnerabilities'
  end
end
