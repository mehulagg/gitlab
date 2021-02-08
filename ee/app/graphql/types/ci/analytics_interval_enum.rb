module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class AnalyticsIntervalEnum < BaseEnum
      graphql_name 'AnalyticsInterval'
      description 'Time intervals used for bucketing analytics data'

      value 'DAILY', 'Data will be presented in daily intervals', value: 'daily'
      value 'MONTHLY', 'Data will be presented in monthly intervals', value: 'monthly'
      value 'ALL', 'Data will be presented in a single interval', value: 'all'
    end
  end
end
