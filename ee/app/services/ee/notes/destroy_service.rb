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
      end
    end
  end
end
