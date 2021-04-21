# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      class TimeConstraint
        def initialize(time_frame, data_source)
          @time_frame = time_frame
          @data_source = data_source
        end

        def build
          time_frame_for(@time_frame, @data_source)
        end

        private

        def time_frame_for(time_frame, data_source)
          case data_source
          when 'database'
            database_time_constraints(time_frame)
          when 'redis_hll'
            redis_hll_time_constraints(time_frame)
          else
            raise "Unknown data source: #{data_source} for TimeConstraint"
          end
        end

        def database_time_constraints(time_frame)
          case time_frame
          when '28d'
            database_last_28_days_time_period
          when 'all'
            {}
          when 'none'
            nil
          else
            raise "Unknown time frame: #{time_frame} for TimeConstraint"
          end
        end

        def redis_hll_time_constraints(time_frame)
          case time_frame
          when '28d'
            redis_hll_last_28_days_time_period
          when '7d'
            redis_hll_last_7_days_time_period
          else
            raise "Unknown time frame: #{time_frame} for TimeConstraint"
          end
        end

        def database_last_28_days_time_period(column: :created_at)
          { column => 30.days.ago..2.days.ago }
        end

        def redis_hll_last_28_days_time_period
          { start_date: 4.weeks.ago.to_date, end_date: Date.current }
        end

        def redis_hll_last_7_days_time_period
          { start_date: 7.days.ago.to_date, end_date: Date.current }
        end
      end
    end
  end
end
