# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class IssueLabelRemoved < LabelBasedStageEvent
          def self.name
            s_("CycleAnalyticsEvent|Issue label was removed")
          end

          def self.identifier
            :issue_label_removed
          end

          def object_type
            Issue
          end

          def subquery
            resource_label_events_with_subquery(:issue_id, label, ::ResourceLabelEvent.actions[:remove], :desc)
          end
        end
      end
    end
  end
end
