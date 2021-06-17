# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class ProcessService < BaseService
      def initialize(escalation)
        @escalation = escalation
        @project = escalation.project
        @oncall_schedule = escalation.oncall_schedule
        @target = escalation.target
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project)
        return if target_already_resolved?
        return if target_status_exceeded_rule?

        notify_recipients
        destroy_escalation!
      end

      private

      attr_reader :escalation, :project, :target, :oncall_schedule

      def target_already_resolved?
        return false unless target.resolved?

        destroy_escalation!
      end

      def target_status_exceeded_rule?
        target.status >= escalation.status_before_type_cast
      end

      def notify_recipients
        NotificationService
          .new
          .async
          .notify_oncall_users_of_alert(oncall_notification_recipients.to_a, target)
      end

      def oncall_notification_recipients
        ::IncidentManagement::OncallUsersFinder.new(project, schedule: oncall_schedule).execute
      end

      def destroy_escalation!
        escalation.destroy!
      end
    end
  end
end
