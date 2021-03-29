# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module EpicActivityUniqueCounter
      # The 'g_project_management' prefix need to be present
      # on epic event names, because they are persisted at the same
      # slot of issue events to allow data aggregation.
      # More information in: https://gitlab.com/gitlab-org/gitlab/-/issues/322405
      EPIC_CREATED = 'g_project_management_epic_created'
      EPIC_TITLE_CHANGED = 'g_project_management_users_updating_epic_titles'
      EPIC_DESCRIPTION_CHANGED = 'g_project_management_users_updating_epic_descriptions'
      EPIC_NOTE_CREATED = 'g_project_management_users_creating_epic_notes'
      EPIC_NOTE_UPDATED = 'g_project_management_users_updating_epic_notes'
      EPIC_NOTE_DESTROYED = 'g_project_management_users_destroying_epic_notes'
      EPIC_START_DATE_SET_AS_FIXED = 'g_project_management_users_setting_epic_start_date_as_fixed'
      EPIC_START_DATE_SET_AS_INHERITED = 'g_project_management_users_setting_epic_start_date_as_inherited'
      EPIC_DUE_DATE_SET_AS_FIXED = 'g_project_management_users_setting_epic_due_date_as_fixed'
      EPIC_DUE_DATE_SET_AS_INHERITED = 'g_project_management_users_setting_epic_due_date_as_inherited'
      EPIC_FIXED_START_DATE_UPDATED = 'g_project_management_users_updating_epic_fixed_start_date'
      EPIC_FIXED_DUE_DATE_UPDATED = 'g_project_management_users_updating_epic_fixed_due_date'
      EPIC_ISSUE_ADDED = 'g_project_management_epic_issue_added'
      EPIC_CLOSED = 'g_project_management_epic_closed'
      EPIC_REOPENED = 'g_project_management_epic_reopened'

      class << self
        def track_epic_created_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_CREATED, author, time)
        end

        def track_epic_title_changed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_TITLE_CHANGED, author, time)
        end

        def track_epic_description_changed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_DESCRIPTION_CHANGED, author, time)
        end

        def track_epic_note_created_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_NOTE_CREATED, author, time)
        end

        def track_epic_note_updated_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_NOTE_UPDATED, author, time)
        end

        def track_epic_note_destroyed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_NOTE_DESTROYED, author, time)
        end

        def track_epic_start_date_set_as_fixed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_START_DATE_SET_AS_FIXED, author, time)
        end

        def track_epic_start_date_set_as_inherited_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_START_DATE_SET_AS_INHERITED, author, time)
        end

        def track_epic_due_date_set_as_fixed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_DUE_DATE_SET_AS_FIXED, author, time)
        end

        def track_epic_due_date_set_as_inherited_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_DUE_DATE_SET_AS_INHERITED, author, time)
        end

        def track_epic_fixed_start_date_updated_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_FIXED_START_DATE_UPDATED, author, time)
        end

        def track_epic_fixed_due_date_updated_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_FIXED_DUE_DATE_UPDATED, author, time)
        end

        def track_epic_issue_added(author:, time: Time.zone.now)
          track_unique_action(EPIC_ISSUE_ADDED, author, time)
        end

        def track_epic_closed_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_CLOSED, author, time)
        end

        def track_epic_reopened_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_REOPENED, author, time)
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
