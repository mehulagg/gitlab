# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class IssueFirstAddedToBoard < MetricsBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Issue first added to a board")
          end

          def self.identifier
            :issue_first_added_to_board
          end

          def object_type
            Issue
          end

          def column_list
            [issue_metrics_table[:first_added_to_board_at]]
          end
        end
      end
    end
  end
end
