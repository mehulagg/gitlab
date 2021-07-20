# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module StageEvents
        class MergeRequestLastEdited < StageEvent
          def self.name
            s_("CycleAnalyticsEvent|Merge request last edited")
          end

          def self.identifier
            :merge_request_last_edited
          end

          def object_type
            MergeRequest
          end

          def column_list
            [mr_table[:last_edited_at]]
          end
        end
      end
    end
  end
end
