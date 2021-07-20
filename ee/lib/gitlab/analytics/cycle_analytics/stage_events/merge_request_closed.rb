# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class MergeRequestClosed < MetricsBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Merge request closed")
          end

          def self.identifier
            :merge_request_closed
          end

          def object_type
            MergeRequest
          end

          def column_list
            [mr_metrics_table[:latest_closed_at]]
          end
        end
      end
    end
  end
end
