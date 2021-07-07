# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class CreateService < BaseService
      def initialize(target, reset_time: nil)
        @target = target
        @project = target.project
        @reset_time = reset_time
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project) && !target.resolved?

        create_escalations(escalation_rules)
      end

      private

      attr_reader :target, :project, :escalation, :reset_time

      def escalation_rules
        min_elapsed_time = reset_time - target.triggered_at if reset_time

        IncidentManagement::EscalationRulesFinder.new(project, min_elapsed_time: min_elapsed_time).execute
      end

      def create_escalations(rules)
        return unless rules

        escalation_id_args = rules.map { |rule| [create_escalation(rule).id] }

        process_escalations(escalation_id_args)
      end

      def create_escalation(rule)
        IncidentManagement::PendingEscalations::Alert.create!(
          target: target,
          rule: rule,
          process_at: rule.elapsed_time_seconds.seconds.after(target.triggered_at)
        )
      end

      def process_escalations(args)
        ::IncidentManagement::PendingEscalations::AlertCheckWorker.bulk_perform_async(args) # rubocop:disable Scalability/BulkPerformWithContext
      end
    end
  end
end
