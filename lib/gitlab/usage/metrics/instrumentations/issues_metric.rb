# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class IssuesMetric < BaseMetric
          def value
            issue_minimum_id = ::Issue.minimum(:id)
            issue_maximum_id = ::Issue.maximum(:id)

            count(Issue, start: issue_minimum_id, finish: issue_maximum_id)
          end
        end
      end
    end
  end
end
