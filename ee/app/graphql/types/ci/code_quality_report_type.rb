# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class CodeQualityReportType < BaseObject
      graphql_name 'CodeQualityReport'
      description 'Represents code quality degradations on the pipeline.'

      field :degradations_count, GraphQL::INT_TYPE, null: false,
        description: 'The total number of code quality degradations.'

      field :all_degradations, Types::Ci::CodeQualityDegradationType.connection_type, null: false,
        description: 'All Code Quality degradations.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
