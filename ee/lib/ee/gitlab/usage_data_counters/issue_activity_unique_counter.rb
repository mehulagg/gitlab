# frozen_string_literal: true

module EE
  module Gitlab
    module UsageDataCounters
      module IssueActivityUniqueCounter
        extend ActiveSupport::Concern

        ISSUE_HEALTH_STATUS_CHANGED = 'g_project_management_issue_health_status_changed'

        class_methods do
          def track_issue_health_status_changed_action(author:, time: Time.zone.now)
            track_unique_action(ISSUE_HEALTH_STATUS_CHANGED, author, time)
          end
        end
      end
    end
  end
end
