# frozen_string_literal: true

module IncidentManagement
  module Escalations
    class ProcessService < BaseService
      def initialize(escalation)
        @escalation = escalation
        @project = escalation.project
        @escalation_policy = escalation.policy
        @alert = escalation.alert
        @process_time = Time.current
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project)

        current_elapsed_time = process_time - escalation.created_at
        notified_elapsed_time = escalation.updated_at - escalation.created_at

        escalation_rules
          .for_status_above(alert.status)
          .for_elapsed_time_between(notified_elapsed_time, current_elapsed_time)
          .each { |rule| escalate_rule(rule) }

        mark_escalation_as_updated!
      end

      private

      attr_reader :project, :escalation, :escalation_policy, :alert, :process_time

      def escalation_rules
        escalation_policy
          .rules
          .includes(:oncall_schedule) # rubocop: disable CodeReuse/ActiveRecord
      end

      def escalate_rule(rule)
        recipients = oncall_notification_recipients(rule)

        notify_oncall(recipients) if recipients.any?
      end

      def notify_oncall(recipients)
        NotificationService
          .new
          .async
          .notify_oncall_users_of_alert(recipients.to_a, alert)
      end

      def oncall_notification_recipients(rule)
        ::IncidentManagement::OncallUsersFinder.new(project, schedule: rule.oncall_schedule).execute
      end

      def mark_escalation_as_updated!
        escalation.touch(time: process_time)
      end
    end
  end
end
