# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        module Issues
          class ByStageMonthlyPlanMetric < BaseMetric
            # rubocop: disable CodeReuse/ActiveRecord
            def value
              distinct_count(::Issue.where(time_period), :author_id)
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
