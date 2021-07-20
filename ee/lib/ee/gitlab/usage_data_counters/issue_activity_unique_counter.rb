# frozen_string_literal: true

module EE
  module Gitlab
    module UsageDataCounters
      module IssueActivityUniqueCounter
        extend ActiveSupport::Concern

        ISSUE_HEALTH_STATUS_CHANGED = 'g_project_management_issue_health_status_changed'
        ISSUE_ITERATION_CHANGED = 'g_project_management_issue_iteration_changed'
        ISSUE_WEIGHT_CHANGED = 'g_project_management_issue_weight_changed'
        ISSUE_ADDED_TO_EPIC = 'g_project_management_issue_added_to_epic'
        ISSUE_REMOVED_FROM_EPIC = 'g_project_management_issue_removed_from_epic'
        ISSUE_CHANGED_EPIC = 'g_project_management_issue_changed_epic'

        class_methods do
          def track_issue_health_status_changed_action(author:)
            track_unique_action(ISSUE_HEALTH_STATUS_CHANGED, author)
          end

          def track_issue_iteration_changed_action(author:)
            track_unique_action(ISSUE_ITERATION_CHANGED, author)
          end

          def track_issue_weight_changed_action(author:)
            track_unique_action(ISSUE_WEIGHT_CHANGED, author)
          end

          def track_issue_added_to_epic_action(author:)
            track_unique_action(ISSUE_ADDED_TO_EPIC, author)
          end

          def track_issue_removed_from_epic_action(author:)
            track_unique_action(ISSUE_REMOVED_FROM_EPIC, author)
          end

          def track_issue_changed_epic_action(author:)
            track_unique_action(ISSUE_CHANGED_EPIC, author)
          end
        end
      end
    end
  end
end
