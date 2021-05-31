# frozen_string_literal: true

module IncidentManagement
  module Escalations
    class ProcessService < BaseService
      include ::AlertManagement::AlertProcessing

      def initialize(escalation)
        @escalation = escalation
        @project = escalation.project
        @escalation_policy = escalation.policy
        @alert = escalation.alert
        @process_time = Time.current
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project)

        rules = escalation_policy.rules

        find_rules_to_escalate(rules).each do |rule|
          escalate_rule!(rule)
        end

        mark_escalation_as_updated!
      end

      private

      attr_reader :project, :escalation, :escalation_policy, :alert, :process_time, :rule_to_escalate

      def find_rules_to_escalate(rules)
        rules.select do |rule|
          status_not_surpassed?(rule) &&
            escalation_time_surpassed_threshold?(rule) &&
            not_previously_escalated?(rule)
        end
      end

      # Compares the enum value of the status
      # A lower value is more urgent than a higher value.
      def status_not_surpassed?(rule)
        rule.status_before_type_cast > alert.status
      end

      def escalation_time_surpassed_threshold?(rule)
        escalation.elapsed_time >= rule.elapsed_time_seconds
      end

      def not_previously_escalated?(rule)
        escalation.updated_at.to_i <= (escalation.created_at + rule.elapsed_time_seconds).to_i
      end

      def escalate_rule!(rule)
        @rule_to_escalate = rule

        notify_oncall if oncall_notification_recipients.any?
        clear_memoization(:oncall_notification_recipients)
      end

      def oncall_notification_recipients
        strong_memoize(:oncall_notification_recipients) do
          ::IncidentManagement::OncallUsersFinder.new(project, schedule: rule_to_escalate.oncall_schedule).execute
        end
      end

      def mark_escalation_as_updated!
        escalation.touch(time: process_time)
      end
    end
  end
end
