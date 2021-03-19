# frozen_string_literal: true

module EE
  module Notes
    module UpdateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(note)
        updated_note = super

        if updated_note&.errors&.empty?
          ::Gitlab::StatusPage.trigger_publish(project, current_user, updated_note)
        end

        note.usage_ping_track_updated_epic_note(current_user) if note.for_epic?

        updated_note
      end
    end
  end
end
