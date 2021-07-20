# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class IssueClosed < StageEvent
          def self.name
            s_("CycleAnalyticsEvent|Issue closed")
          end

          def self.identifier
            :issue_closed
          end

          def object_type
            Issue
          end

          def column_list
            [issue_table[:closed_at]]
          end
        end
      end
    end
  end
end
