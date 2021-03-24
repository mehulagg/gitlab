# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class BaseMetric
          include Gitlab::Utils::UsageData

          # Returns usage data for metric as hash prepared for Usage Ping JSON payload
          def usage_data
            Gitlab::Usage::Metrics::KeyPathProcessor.unflatten_key_path(definition.key_path, value)
          end

          # Overwrite this method with the metric implementation
          def value
            nil
          end

          private

          def time_period
            case definition.attributes[:time_period]
            when '28d'
              last_28_days_time_period
            else
              {}
            end
          end

          def last_28_days_time_period(column: :created_at)
            { column => 30.days.ago..2.days.ago }
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def definition
            Gitlab::Usage::MetricDefinition.find_by(instrumentation_class: self.class.name)
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
