# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class IssuesByStagePlanMetric < BaseMetric
          def value
            distinct_count(::Issue.where(time_period), :author_id)
          end
        end
      end
    end
  end
end
