# frozen_string_literal: true

module Gitlab
  module ProductIntelligence
    module AggregatedMetrics
      module Sources
        class PostgresHll
          class << self
            def calculate_events_union(event_names:, start_date:, end_date:, recorded_at:)
              buckets = Gitlab::Database::PostgresHll::Buckets.new
              time_period = { _column: (start_date..end_date) } if start_date && end_date

              Array(event_names).each do |event|
                json = read_aggregated_metric(event_name: event, time_period: time_period, recorded_at: recorded_at)
                return -1 unless json

                buckets.merge_hash!(Gitlab::Json.parse(json))
              end
              buckets.estimated_distinct_count
            end

            def read_aggregated_metric(event_name: , time_period:, recorded_at:)
              Gitlab::Redis::SharedState.with do |redis|
                redis.get(redis_key(event_name: event_name, time_period: time_period, recorded_at: recorded_at))
              end
            end

            def save_aggregated_metrics(metric_name:, time_period:, recorded_at_timestamp:, data:)
              unless data.is_a? ::Gitlab::Database::PostgresHll::Buckets
                Gitlab::ErrorTracking.track_and_raise_for_dev_exception(StandardError.new("Unsupported data type: #{data.class}"))
                return
              end

              # the longest recorded usage ping generation time for gitlab.com
              # was below 40 hours, there is added error margin of 20 h
              usage_ping_generation_period = 80.hours

              Gitlab::Redis::SharedState.with do |redis|
                redis.set(
                  redis_key(event_name: metric_name, time_period: time_period, recorded_at: recorded_at_timestamp),
                  data.to_json,
                  ex: usage_ping_generation_period
                )
              end
            rescue ::Redis::CommandError => e
              Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
            end

            def redis_key(event_name: , time_period:, recorded_at:)
              # add timestamp at the end of the key to avoid stale keys if
              # usage ping job is retried
              "#{event_name}_#{time_period_to_human_name(time_period)}-#{recorded_at}"
            end

            def time_period_to_human_name(time_period)
              return Gitlab::Utils::UsageData::ALL_TIME_PERIOD_HUMAN_NAME if time_period.blank?

              date_range = time_period.values[0]
              start_date = date_range.first.to_date
              end_date = date_range.last.to_date

              if (end_date - start_date).to_i > 7
                Gitlab::Utils::UsageData::MONTHLY_PERIOD_HUMAN_NAME
              else
                Gitlab::Utils::UsageData::WEEKLY_PERIOD_HUMAN_NAME
              end
            end
          end
        end
      end
    end
  end
end
