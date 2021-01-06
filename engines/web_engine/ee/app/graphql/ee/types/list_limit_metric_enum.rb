# frozen_string_literal: true

module EE
  module Types
    class ListLimitMetricEnum < ::Types::BaseEnum
      graphql_name 'ListLimitMetric'
      description 'List limit metric setting'

      value 'all_metrics'
      value 'issue_count'
      value 'issue_weights'
    end
  end
end
