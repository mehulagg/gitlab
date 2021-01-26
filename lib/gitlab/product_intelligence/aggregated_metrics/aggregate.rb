# frozen_string_literal: true

module Gitlab
  module ProductIntelligence
    module AggregatedMetrics
      UNION_OF_AGGREGATED_METRICS = 'OR'
      INTERSECTION_OF_AGGREGATED_METRICS = 'AND'
      ALLOWED_METRICS_AGGREGATIONS = [UNION_OF_AGGREGATED_METRICS, INTERSECTION_OF_AGGREGATED_METRICS].freeze
      AGGREGATED_METRICS_PATH = Rails.root.join('lib/gitlab/usage_data_counters/aggregated_metrics/*.yml')
      # SOURCES = {
      #   'redis' => Sources::Redis,
      #   'postgres' => Sources::Postgres,
      # }

      class Aggregate
        def initialize
          @aggregated_metrics = load_events(AGGREGATED_METRICS_PATH)
        end

        def aggregated_metrics_monthly_data
          aggregated_metrics_data(4.weeks.ago.to_date)
        end

        def aggregated_metrics_weekly_data
          aggregated_metrics_data(7.days.ago.to_date)
        end

        private

        attr_accessor :aggregated_metrics

        def load_events(wildcard)
          Dir[wildcard].each_with_object([]) do |path, events|
            events.push(*load_yaml_from_path(path))
          end
        end

        def load_yaml_from_path(path)
          YAML.safe_load(File.read(path))&.map(&:with_indifferent_access)
        end

        def aggregated_metrics_data(start_date)
          aggregated_metrics.each_with_object({}) do |aggregation, weekly_data|
            next if aggregation[:feature_flag] && Feature.disabled?(aggregation[:feature_flag], default_enabled: false, type: :development)

            weekly_data[aggregation[:name]] = calculate_count_for_aggregation(aggregation, start_date: start_date, end_date: Date.current)
          end
        end

        def calculate_count_for_aggregation(aggregation, start_date:, end_date:)
          case aggregation[:operator]
          when UNION_OF_AGGREGATED_METRICS
            Sources::RedisHll.calculate_events_union(event_names: aggregation[:events], start_date: start_date, end_date: end_date)
          when INTERSECTION_OF_AGGREGATED_METRICS
            calculate_events_intersections(event_names: aggregation[:events], start_date: start_date, end_date: end_date)
          else
            raise UnknownAggregationOperator, "Events should be aggregated with one of operators #{ALLOWED_METRICS_AGGREGATIONS}"
          end
        end

        # calculate intersection of 'n' sets based on inclusion exclusion principle https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle
        # this method will be extracted to dedicated module with https://gitlab.com/gitlab-org/gitlab/-/issues/273391
        def calculate_events_intersections(event_names:, start_date:, end_date:, subset_powers_cache: Hash.new({}))
          # calculate power of intersection of all given metrics from inclusion exclusion principle
          # |A + B + C| = (|A| + |B| + |C|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C|)  =>
          # |A & B & C| = - (|A| + |B| + |C|) + (|A & B| + |A & C| + .. + |C & D|) + |A + B + C|
          # |A + B + C + D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A & B & C & D| =>
          # |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) - |A + B + C + D|

          # calculate each components of equation except for the last one |A & B & C & D| = (|A| + |B| + |C| + |D|) - (|A & B| + |A & C| + .. + |C & D|) + (|A & B & C| + |B & C & D|) -  ...
          subset_powers_data = subsets_intersection_powers(event_names, start_date, end_date, subset_powers_cache)

          # calculate last component of the equation  |A & B & C & D| = .... - |A + B + C + D|
          power_of_union_of_all_events = begin
                                           subset_powers_cache[event_names.size][event_names.join('_+_')] ||= \
                                            Sources::RedisHll.calculate_events_union(event_names: event_names, start_date: start_date, end_date: end_date)
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
          sum_of_all_subset_powers + (subset_powers_size_even ? power_of_union_of_all_events : -power_of_union_of_all_events)
        end

        def sum_subset_powers(subset_powers_data, subset_powers_size_even)
          sum_without_sign =  subset_powers_data.to_enum.with_index.sum do |value, index|
            (index + 1).odd? ? value : -value
          end

          (subset_powers_size_even ? -1 : 1) * sum_without_sign
        end

        def subsets_intersection_powers(event_names, start_date, end_date, subset_powers_cache)
          subset_sizes = (1..(event_names.size - 1))

          subset_sizes.map do |subset_size|
            if subset_size > 1
              # calculate sum of powers of intersection between each subset (with given size) of metrics:  #|A + B + C + D| = ... - (|A & B| + |A & C| + .. + |C & D|)
              event_names.combination(subset_size).sum do |events_subset|
                subset_powers_cache[subset_size][events_subset.join('_&_')] ||= \
                  calculate_events_intersections(event_names: events_subset, start_date: start_date, end_date: end_date, subset_powers_cache: subset_powers_cache)
              end
            else
              # calculate sum of powers of each set (metric) alone  #|A + B + C + D| = (|A| + |B| + |C| + |D|) - ...
              event_names.sum do |event|
                subset_powers_cache[subset_size][event] ||= \
                  Sources::RedisHll.calculate_events_union(event_names: event, start_date: start_date, end_date: end_date)
              end
            end
          end
        end
      end
    end
  end
end
