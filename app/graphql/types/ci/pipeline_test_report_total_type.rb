# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class PipelineTestReportTotalType < BaseObject
      graphql_name 'PipelineTestReportTotal'
      description 'The total test report statistics'

      field :time, GraphQL::FLOAT_TYPE, null: true,
        description: 'The total duration of the tests'

      field :count, GraphQL::INT_TYPE, null: true,
        description: 'The total number of the test cases'

      field :success, GraphQL::INT_TYPE, null: true,
        description: 'The total number of test cases that succeeded'

      field :failed, GraphQL::INT_TYPE, null: true,
        description: 'The total number of test cases that failed'

      field :skipped, GraphQL::INT_TYPE, null: true,
        description: 'The total number of test cases that were skipped'

      field :error, GraphQL::INT_TYPE, null: true,
        description: 'The total number of test cases that had an error'

      field :suite_error, GraphQL::STRING_TYPE, null: true,
        description: 'The test suite error message'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
