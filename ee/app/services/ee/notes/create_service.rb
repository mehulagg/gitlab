# frozen_string_literal: true

module EE
  module Notes
    module CreateService
      extend ::Gitlab::Utils::Override

      private

      override :track_event
      def track_event(note, user)
        note.noteable.usage_ping_track_create_note(user) if note.noteable.respond_to?(:usage_ping_track_create_note)

        super(note, user)
      end
    end
  end
end
