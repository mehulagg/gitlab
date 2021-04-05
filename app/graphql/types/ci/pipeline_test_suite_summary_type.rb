# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class PipelineTestSuiteSummaryType < BaseObject
      graphql_name 'PipelineTestSuiteSummary'
      description 'Represents a test suite summary in a pipeline test report'

      connection_type_class(Types::CountableConnectionType)

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the test suite'

      field :total, Types::Ci::PipelineTestReportTotalType, null: true,
        description: 'The total statistics for the test suite'
      
      field :build_ids, [GraphQL::ID_TYPE], null: true,
        description: 'The IDs of the builds used to run the test suite'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
