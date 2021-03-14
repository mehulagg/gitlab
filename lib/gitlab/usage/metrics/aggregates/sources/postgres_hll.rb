# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Aggregates
        module Sources
          class PostgresHll
            class << self
              def calculate_metrics_union(metric_names:, start_date:, end_date:, recorded_at:)
                time_period = start_date && end_date ? (start_date..end_date) : nil

                Array(metric_names).each_with_object(Gitlab::Database::PostgresHll::Buckets.new) do |event, buckets|
                  json = read_aggregated_metric(metric_name: event, time_period: time_period, recorded_at: recorded_at)
                  raise UnionNotAvailable, "Union data not available for #{metric_names}" unless json

                  buckets.merge_hash!(Gitlab::Json.parse(json))
                end.estimated_distinct_count
              end

              # calculate intersection of 'n' sets based on inclusion exclusion principle https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle
              def calculate_metrics_intersections(metric_names:, start_date:, end_date:, recorded_at:, subset_powers_cache: Hash.new({}))
                # calculate power of intersection of all given metrics from inclusion exclusion principle
                # |A + B + C| = (|A| + |B| + |C|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C|)  =>
                # |A & B & C| = - (|A| + |B| + |C|) + (|A & B| + |A & C| + .. + |C & D|) + |A + B + C|
                # |A + B + C + D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A & B & C & D| =>
                # |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A + B + C + D|

                # calculate each components of equation except for the last one |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) -  ...
                subset_powers_data = subsets_intersection_powers(metric_names, start_date, end_date, recorded_at, subset_powers_cache)

                # calculate last component of the equation  |A & B & C & D| = .... - |A + B + C + D|
                power_of_union_of_all_metrics = begin
                  subset_powers_cache[metric_names.size][metric_names.join('_+_')] ||= \
                    calculate_metrics_union(metric_names: metric_names, start_date: start_date, end_date: end_date, recorded_at: recorded_at)
                end

                # in order to determine if part of equation (|A & B & C|, |A & B & C & D|), that represents the intersection that we need to calculate,
                # is positive or negative in particular equation we need to determine if number of subsets is even or odd. Please take a look at two examples below
                # |A + B + C| = (|A| + |B| + |C|) - (|A & B| + |A & C| + .. + |C & D|) + |A & B & C|  =>
                # |A & B & C| = - (|A| + |B| + |C|) + (|A & B| + |A & C| + .. + |C & D|) + |A + B + C|
                # |A + B + C + D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A & B & C & D| =>
                # |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A + B + C + D|
                subset_powers_size_even = subset_powers_data.size.even?

                # sum all components of equation except for the last one |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) -  ... =>
                sum_of_all_subset_powers = sum_subset_powers(subset_powers_data, subset_powers_size_even)

                # add last component of the equation |A & B & C & D| = sum_of_all_subset_powers - |A + B + C + D|
                sum_of_all_subset_powers + (subset_powers_size_even ? power_of_union_of_all_metrics : -power_of_union_of_all_metrics)
              end

              def save_aggregated_metrics(metric_name:, time_period:, recorded_at_timestamp:, data:)
                unless data.is_a? ::Gitlab::Database::PostgresHll::Buckets
                  Gitlab::ErrorTracking.track_and_raise_for_dev_exception(StandardError.new("Unsupported data type: #{data.class}"))
                  return
                end

                # Usage Ping report generation for gitlab.com is very long running process
                # to make sure that saved keys are available at the end of report generation process
                # lets use triple max generation time
                keys_expiration = ::Gitlab::UsageData::MAX_GENERATION_TIME_FOR_SAAS * 3

                Gitlab::Redis::SharedState.with do |redis|
                  redis.set(
                    redis_key(metric_name: metric_name, time_period: time_period&.values&.first, recorded_at: recorded_at_timestamp),
                    data.to_json,
                    ex: keys_expiration
                  )
                end
              rescue ::Redis::CommandError => e
                Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
              end

              private

              def read_aggregated_metric(metric_name:, time_period:, recorded_at:)
                Gitlab::Redis::SharedState.with do |redis|
                  redis.get(redis_key(metric_name: metric_name, time_period: time_period, recorded_at: recorded_at))
                end
              end

              def redis_key(metric_name:, time_period:, recorded_at:)
                # add timestamp at the end of the key to avoid stale keys if
                # usage ping job is retried
                "#{metric_name}_#{time_period_to_human_name(time_period)}-#{recorded_at.to_i}"
              end

              def time_period_to_human_name(time_period)
                return Gitlab::Utils::UsageData::ALL_TIME_TIME_FRAME_NAME if time_period.blank?

                start_date = time_period.first.to_date
                end_date = time_period.last.to_date

                if (end_date - start_date).to_i > 7
                  Gitlab::Utils::UsageData::TWENTY_EIGHT_DAYS_TIME_FRAME_NAME
                else
                  Gitlab::Utils::UsageData::SEVEN_DAYS_TIME_FRAME_NAME
                end
              end

              def subsets_intersection_powers(metric_names, start_date, end_date, recorded_at, subset_powers_cache)
                subset_sizes = (1...metric_names.size)

                subset_sizes.map do |subset_size|
                  if subset_size > 1
                    # calculate sum of powers of intersection between each subset (with given size) of metrics:  #|A + B + C + D| = ... - (|A & B| + |A & C| + .. + |C & D|)
                    metric_names.combination(subset_size).sum do |metrics_subset|
                      subset_powers_cache[subset_size][metrics_subset.join('_&_')] ||=
                        calculate_metrics_intersections(metric_names: metrics_subset, start_date: start_date, end_date: end_date, recorded_at: recorded_at, subset_powers_cache: subset_powers_cache)
                    end
                  else
                    # calculate sum of powers of each set (metric) alone  #|A + B + C + D| = (|A| + |B| + |C| + |D|) - ...
                    metric_names.sum do |metric|
                      subset_powers_cache[subset_size][metric] ||= \
                        calculate_metrics_union(metric_names: metric, start_date: start_date, end_date: end_date, recorded_at: recorded_at)
                    end
                  end
                end
              end

              def sum_subset_powers(subset_powers_data, subset_powers_size_even)
                sum_without_sign =  subset_powers_data.to_enum.with_index.sum do |value, index|
                  (index + 1).odd? ? value : -value
                end

                (subset_powers_size_even ? -1 : 1) * sum_without_sign
              end
            end
          end
        end
      end
    end
  end
end
