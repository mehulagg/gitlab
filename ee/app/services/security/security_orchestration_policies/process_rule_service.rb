# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class ProcessRuleService < ::BaseService
      def initialize(policy_configuration, policy_index, policy)
        @policy_configuration = policy_configuration
        @policy_index = policy_index
        @policy = policy
      end

      def execute
        destroy_old_schedule_rules
        create_new_schedule_rules
      end

      private

      attr_reader :policy_configuration, :policy_index, :policy

      def destroy_old_schedule_rules
        policy_configuration
          .rule_schedules
          .delete_all
      end

      def create_new_schedule_rules
        policy[:rules]
          .select { |rule| rule[:type] == Security::OrchestrationPolicyConfiguration::RULE_TYPES[:schedule] }
          .each do |rule|
          Security::OrchestrationPolicyRuleSchedule
            .new(
              security_orchestration_policy_configuration: policy_configuration,
              policy_index: policy_index,
              cron: rule[:cadence],
              owner: policy.policy_last_updated_by
            )
            .save!
        end
      end
    end
  end
end
