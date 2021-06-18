# frozen_string_literal: true

module EE
  module Types
    class ListLimitMetricEnum < ::Types::BaseEnum
      graphql_name 'ListLimitMetric'
      description 'List limit metric setting'

      value 'all_metrics', description: 'Limit list by number and total weight of issues.'
      value 'issue_count', description: 'Limit list by number of issues.'
      value 'issue_weights', description: 'Limit list by total weight of issues.'
    end
  end
end
