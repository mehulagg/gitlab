# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class IssueFirstAssociatedWithMilestone < MetricsBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Issue first associated with a milestone")
          end

          def self.identifier
            :issue_first_associated_with_milestone
          end

          def object_type
            Issue
          end

          def column_list
            [issue_metrics_table[:first_associated_with_milestone_at]]
          end
        end
      end
    end
  end
end
