# frozen_string_literal: true

module EE
  module AlertManagement
    module AlertProcessing
      extend ::Gitlab::Utils::Override

      private

      override :complete_post_processing_tasks
      def complete_post_processing_tasks
        super

        notify_oncall
      end

      def notify_oncall
        notification_service
          .async
          .notify_oncall_participants_of_alert(oncall_notification_recipients, alert)
      end

      def oncall_notification_recipients
        ::IncidentManagement::OncallParticipantsFinder
          .new(project, is_oncall: true)
          .execute
          .includes(:user)
          .map(&:user)
          .uniq
      end
    end
  end
end
