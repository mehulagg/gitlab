# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    # This is presented through `PipelineType` that has its own authorization
    class PipelineTestReportSummaryType < BaseObject
      graphql_name 'PipelineTestReportSummary'
      description 'Represents the test report for a pipeline'

      field :total, Types::Ci::PipelineTestReportTotalType, null: true,
        description: 'The total report statistics for a pipeline test report'
      
      field :test_suites, Types::Ci::PipelineTestSuiteSummaryType.connection_type, null: true,
        description: 'Test suites belonging to a pipeline test report'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
