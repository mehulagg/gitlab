# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class BaseMetric
          include Gitlab::Utils::UsageData

          attr_reader :time_constraints

          def initialize(time_constraints:)
            @time_constraints = time_constraints
          end

          alias_method :database_time_constraints, :time_constraints
          alias_method :redis_hll_time_constraints, :time_constraints
        end
      end
    end
  end
end
