# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresHll
      class Buckets
        TOTAL_BUCKETS = 512

        def initialize(buckets = {})
          @buckets = buckets
        end

        def estimated_distinct_count
          @estimated_distinct_count ||= estimate_cardinality
        end

        def merge_hash!(other_buckets_hash)
          buckets.merge!(other_buckets_hash) {|_key, old, new| new > old ? new : old }
        end

        def to_json(_ = nil)
          buckets.to_json
        end

        private

        attr_accessor :buckets

        # arbitrary values that are present in #estimate_cardinality
        # are sourced from https://www.sisense.com/blog/hyperloglog-in-pure-sql/
        # article, they are not representing any entity and serves as tune value
        # for the whole equation
        def estimate_cardinality
          num_zero_buckets = TOTAL_BUCKETS - buckets.size

          num_uniques = (
            ((TOTAL_BUCKETS**2) * (0.7213 / (1 + 1.079 / TOTAL_BUCKETS))) /
            (num_zero_buckets + buckets.values.sum { |bucket_hash| 2**(-1 * bucket_hash)} )
          ).to_i

          if num_zero_buckets > 0 && num_uniques < 2.5 * TOTAL_BUCKETS
            ((0.7213 / (1 + 1.079 / TOTAL_BUCKETS)) * (TOTAL_BUCKETS *
              Math.log2(TOTAL_BUCKETS.to_f / num_zero_buckets)))
          else
            num_uniques
          end
        end
      end
    end
  end
end
