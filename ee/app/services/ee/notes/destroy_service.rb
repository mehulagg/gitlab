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

        track_note_removal_usage_epics(current_user) if note.for_epic?
      end

      private

      def track_note_removal_usage_epics(user)
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_note_destroyed_action(user: user)
      end
    end
  end
end
