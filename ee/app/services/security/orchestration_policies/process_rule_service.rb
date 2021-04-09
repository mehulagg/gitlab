# frozen_string_literal: true

module Security
  module OrchestrationPolicies
    class ProcessRuleService < ::BaseService
      include Gitlab::Utils::StrongMemoize

      def initialize(security_orchestration_policy_configuration, policy_index, policy)
        @security_orchestration_policy_configuration = security_orchestration_policy_configuration
        @policy_index = policy_index
        @policy = policy
      end

      def execute
        destroy_old_schedule_rules
        create_new_schedule_rules
      end

      private

      attr_reader :security_orchestration_policy_configuration, :policy_index, :policy

      def destroy_old_schedule_rules
        security_orchestration_policy_configuration
          .rule_schedules
          .delete_all
      end

      def create_new_schedule_rules
        policy['rules'].each do |rule|
          Security::OrchestrationPolicyRuleSchedule
            .new(security_orchestration_policy_configuration: security_orchestration_policy_configuration, policy_index: policy_index, cron: rule['cron'], owner: policy_user)
            .save!
        end
      end

      def policy_user
        strong_memoize(:policy_user) do
          UserFinder.new(policy['user']).find_by_username!
        end
      end
    end
  end
end
