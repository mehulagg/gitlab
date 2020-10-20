# frozen_string_literal: true

module Gitlab
  module Database
    module BatchPostgresHllDistinctCount
      def batch_distinct_count(relation, column = nil, batch_size: nil, start: nil, finish: nil)
        BatchCounter123.new(relation, column: column).count(batch_size: batch_size, start: start, finish: finish)
      end

      class << self
        include BatchPostgresHllDistinctCount
      end
    end

    class BatchCounter123
      FALLBACK = -1
      MIN_REQUIRED_BATCH_SIZE = 1_250
      MAX_ALLOWED_LOOPS = 10_000
      SLEEP_TIME_IN_SECONDS = 0.01 # 10 msec sleep

      # Each query should take < 500ms https://gitlab.com/gitlab-org/gitlab/-/merge_requests/22705
      DEFAULT_BATCH_SIZE = 100_000

      AGGREGATE_SQL = <<~SQL
        hll_union(%{accumulated_hll_blob}, %{next_batch_subquery})
      SQL

      BUCKETED_DATA_SQL = <<~SQL
        SELECT
           (('X' || md5(%{column}::text))::bit(32)::int) & (512 - 1) as bucket_num,
           (31 - floor(log(2, min((('X' || md5(%{column}::text))::bit(32)::int) & ~(1 << 31)))))::int
         AS bucket_hash
         FROM %{relation}
         WHERE %{pkey} >= %{batch_start} AND id < %{batch_end} 
         GROUP BY 1 ORDER BY 1
      SQL

      def initialize(relation, column: nil, operation_args: nil)
        @relation = relation
        @column = column || relation.primary_key
        @operation_args = operation_args
      end

      def unwanted_configuration?(finish, batch_size, start)
        batch_size <= MIN_REQUIRED_BATCH_SIZE ||
          (finish - start) / batch_size >= MAX_ALLOWED_LOOPS ||
          start > finish
      end

      def count(batch_size: nil, start: nil, finish: nil)
        raise 'BatchCount can not be run inside a transaction' if ActiveRecord::Base.connection.transaction_open?
        raise 'Use distinct count only with non id fields' if @column == :id

        batch_size ||= DEFAULT_BATCH_SIZE

        start = actual_start(start)
        finish = actual_finish(finish)

        raise "Batch counting expects positive values only for #{@column}" if start < 0 || finish < 0
        return FALLBACK if unwanted_configuration?(finish, batch_size, start)

        batch_start = start
        hll_blob = {}

        while batch_start <= finish
          begin
            batch_hll_blob = batch_fetch(batch_start, batch_start + batch_size).map(&:values).to_h

            hll_blob = hll_blob.merge(batch_hll_blob)  {|_key, old, new| new > old ? new : old }
            batch_start += batch_size
          rescue ActiveRecord::QueryCanceled
            # retry with a safe batch size & warmer cache
            if batch_size >= 2 * MIN_REQUIRED_BATCH_SIZE
              batch_size /= 2
            else
              return FALLBACK
            end
          end
          sleep(SLEEP_TIME_IN_SECONDS)
        end

        estimate_cardinality(hll_blob)
      end

      private

      def estimate_cardinality(hll_blob)
        num_zero_buckets = 512 - hll_blob.size

        num_uniques = (
          ((512**2) * (0.7213 / (1 + 1.079 / 512))) /
            (num_zero_buckets + hll_blob.values.sum { |bucket_hash| 2**(-1 * bucket_hash)} )
        ).to_i

        if  num_uniques < 2.5 * 512 and num_zero_buckets > 0
          ((0.7213 / (1 + 1.079 / 512)) * (512 *
            Math.log2(512.0 / num_zero_buckets)))
        else
          num_uniques
        end
      end

      def batch_fetch(start, finish)
        @relation.connection.execute(BUCKETED_DATA_SQL % { column: @column, relation: @relation.table_name, pkey: @relation.primary_key, batch_start: start, batch_end: (finish - 1) })
      end

      def actual_start(start)
        start || @relation.unscope(:group, :having).minimum(@column) || 0
      end

      def actual_finish(finish)
        finish || @relation.unscope(:group, :having).maximum(@column) || 0
      end
    end
  end
end
