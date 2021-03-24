# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        module Issues
          class ByStagePlanMetric < BaseMetric
            def value
              distinct_count(::Issue, :author_id)
            end
          end
        end
      end
    end
  end
end
