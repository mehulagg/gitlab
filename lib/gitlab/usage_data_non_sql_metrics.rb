# frozen_string_literal: true

module Gitlab
  class UsageDataNonSqlMetrics < UsageData
    SQL_METRIC_DEFAULT = -2

    class << self
      def count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
        SQL_METRIC_DEFAULT
      end

      def distinct_count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
        SQL_METRIC_DEFAULT
      end

      def estimate_batch_distinct_count(relation, column = nil, batch_size: nil, start: nil, finish: nil)
        SQL_METRIC_DEFAULT
      end

      def sum(relation, column, batch_size: nil, start: nil, finish: nil)
        SQL_METRIC_DEFAULT
      end

      def histogram(relation, column, buckets:, bucket_size:)
        SQL_METRIC_DEFAULT
      end
    end
  end
end
