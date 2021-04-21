# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class BaseMetric
          include Gitlab::Utils::UsageData
          # Usage example
          #
          # class UuidMetric < BaseMetric
          #   value do
          #     Gitlab::CurrentSettings.uuid
          #   end
          # end
          attr_reader :time_constraints

          def initialize(time_constraints:)
            @time_constraints = time_constraints
          end

          alias_method :database_time_constraints, :time_constraints
          alias_method :redis_hll_time_constraints, :time_constraints

          class << self
            def value(&block)
              @metric_value = block
            end

            attr_reader :metric_value
          end

          def value
            alt_usage_data do
              self.class.metric_value.call
            end
          end
        end
      end
    end
  end
end
