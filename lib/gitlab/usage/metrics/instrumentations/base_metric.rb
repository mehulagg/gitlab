# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class BaseMetric
          include Gitlab::Utils::UsageData

          # Returns usage data for metric as hash prepared for Usage Ping JSON payload
          def usage_data
            unflatten_key_path(definition.key_path, value)
          end

          def value
            nil
          end

          private

          def time_period
            case definition.attributes[:time_period]
            when '28d'
              { created_at: 30.days.ago..2.days.ago }
            else
              {}
            end
          end

          # This doesn belong in this class, is not domain specifc
          # Consider moving this out
          def unflatten_key_path(key_path, value)
            unflatten(key_path.split('.'), value)
          end

          def unflatten(keys, value)
            loop do
              value = { keys.pop.to_sym => value }
              break if keys.blank?
            end
            value
          end

          def definition
            Gitlab::Usage::MetricDefinition.find_by(instrumentation: self.class.name)
          end

          def metrics_definitions
            @metrics_definitions ||= Gitlab::Usage::MetricDefinition.definitions
          end
        end
      end
    end
  end
end
