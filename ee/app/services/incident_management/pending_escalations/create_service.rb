# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class CreateService < BaseService
      def initialize(target)
        @target = target
        @project = target.project
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project) && !target.resolved?

        policy = escalation_policies.first

        return unless policy

        create_escalations(policy.rules)
      end

      private

      attr_reader :target, :project, :escalation

      def escalation_policies
        project.incident_management_escalation_policies.with_rules
      end

      def create_escalations(rules)
        rules.each do |rule|
          escalaton = create_escalation(rule)
          process_escalation(escalaton) if rule.elapsed_time_seconds == 0
        end
      end

      def create_escalation(rule)
        target.pending_escalations.create!(
          rule: rule,
          schedule_id: rule.oncall_schedule_id,
          status: rule.status,
          process_at: rule.elapsed_time_seconds.seconds.after(target.created_at)
        )
      end

      def process_escalation(escalation)
        ::IncidentManagement::PendingEscalations::ProcessService.new(escalation).execute
      end
    end
  end
end
