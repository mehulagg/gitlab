# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class IssueLastEdited < StageEvent
          def self.name
            s_("CycleAnalyticsEvent|Issue last edited")
          end

          def self.identifier
            :issue_last_edited
          end

          def object_type
            Issue
          end

          def column_list
            [issue_table[:last_edited_at]]
          end
        end
      end
    end
  end
end
