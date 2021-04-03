# frozen_string_literal: true

module EE
  module Notes
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(note)
        super

        ::Analytics::RefreshCommentsData.for_note(note)&.execute(force: true)
        ::Gitlab::StatusPage.trigger_publish(project, current_user, note)

        track_note_removal_usage_epics if note.for_epic?
      end

      private

      def track_note_removal_usage_epics
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_note_destroyed_action(author: current_user)
      end
    end
  end
end
