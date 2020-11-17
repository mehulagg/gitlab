# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class VulnerabilitiesCountByDayType < BaseObject
    graphql_name 'VulnerabilitiesCountByDay'
    description 'Represents the count of vulnerabilities by severity on a particular day. This data is retained for 365 days'

    field :date, GraphQL::Types::ISO8601Date, null: false,
          description: 'Date for the count'

    field :total, GraphQL::INT_TYPE, null: false,
          description: 'Total number of vulnerabilities on a particular day'

    ::Vulnerabilities::Finding::SEVERITY_LEVELS.keys.each do |severity|
      field severity.to_s, GraphQL::INT_TYPE, null: false,
            description: "Total number of vulnerabilities on a particular day with #{severity} severity"
    end
  end
end
