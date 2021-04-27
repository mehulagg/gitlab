# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class MergeRequestFirstCommitAt < MetricsBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Merge request first commit time")
          end

          def self.identifier
            :merge_request_first_commit_at
          end

          def object_type
            MergeRequest
          end

          def column_list
            [mr_metrics_table[:first_commit_at]]
          end
        end
      end
    end
  end
end
