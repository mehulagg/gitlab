# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class MergeRequestLabelRemoved < LabelBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Merge request label was removed")
          end

          def self.identifier
            :merge_request_label_removed
          end

          def markdown_description
            s_("CycleAnalyticsEvent|%{label_reference} label was removed from the merge request") % { label_reference: label.to_reference }
          end

          def object_type
            MergeRequest
          end

          def subquery
            resource_label_events_with_subquery(:merge_request_id, label, ::ResourceLabelEvent.actions[:remove], :desc)
          end
        end
      end
    end
  end
end
