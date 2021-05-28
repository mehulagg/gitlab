# frozen_string_literal: true

module IncidentManagement
  module Escalations
    class ProcessService < BaseService
      include ::AlertManagement::AlertProcessing

      def initialize(escalation, zero_minute_escalation: false)
        @escalation = escalation
        @project = escalation.project
        @escalation_policy = escalation.policy
        @alert = escalation.alert
        @zero_minute_escalation = zero_minute_escalation
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project)

        # Rules, with largest escalation time offset first i.e 100, 60, 30, 20
        rules = escalation_policy.rules.ordered_by_elapsed_time_seconds

        @rule_to_escalate = find_rule_to_escalate(rules) # TODO find zero min escalation if set
        escalate_rule!
      end

      private

      attr_reader :project, :escalation, :escalation_policy, :alert, :zero_minute_escalation, :rule_to_escalate

      def find_rule_to_escalate(rules)
        rules.detect do |rule|
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

      def escalate_rule!
        return unless rule_to_escalate

        notify_oncall if oncall_notification_recipients.any?
        mark_escalation_as_updated!
      end

      def oncall_notification_recipients
        strong_memoize(:oncall_notification_recipients) do
          ::IncidentManagement::OncallUsersFinder.new(project, schedule: rule_to_escalate.oncall_schedule).execute
        end
      end

      def mark_escalation_as_updated!
        escalation.touch
      end
    end
  end
end
