# frozen_string_literal: true

module Types
  class DoraMetricBucketingIntervalEnum < BaseEnum
    graphql_name 'DoraMetricBucketingInterval'
    description 'All possible ways that DORA metrics can be aggregated.'

    value 'ALL', description: 'All data points are combined into a single value.', value: 'all'
    value 'MONTHLY', description: 'Data points are combined into chunks by month.', value: 'monthly'
    value 'DAILY', description: 'Data points are combined into chunks by day.', value: 'daily'
  end
end
