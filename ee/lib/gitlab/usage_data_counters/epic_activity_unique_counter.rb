# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module EpicActivityUniqueCounter
      # The 'g_project_management' prefix need to be present
      # on epic event names, because they are persisted at the same
      # slot of issue events to allow data aggregation.
      # More information in: https://gitlab.com/gitlab-org/gitlab/-/issues/322405
      EPIC_CREATED = 'g_project_management_epic_created'
      EPIC_CLOSED = 'g_project_management_epic_closed'
      EPIC_REOPEN = 'g_project_management_epic_reopened'

      class << self
        def track_epic_created_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_CREATED, author, time)
        end

        def track_epic_closed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_CLOSED, author, time)
        end

        def track_epic_reopened_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_REOPEN, author, time)
        end

        private

        def track_unique_action(action, author, time)
          return unless Feature.enabled?(:track_epics_activity, default_enabled: true)
          return unless author

          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(action, values: author.id, time: time)
        end
      end
    end
  end
end
