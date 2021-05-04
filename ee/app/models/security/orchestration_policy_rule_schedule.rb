# frozen_string_literal: true

module Security
  class OrchestrationPolicyRuleSchedule < ApplicationRecord
    self.table_name = 'security_orchestration_policy_rule_schedules'

    belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
    belongs_to :security_orchestration_policy_configuration,
               class_name: 'Security::OrchestrationPolicyConfiguration',
               foreign_key: 'security_orchestration_policy_configuration_id'

    validates :owner, presence: true
    validates :security_orchestration_policy_configuration, presence: true
    validates :cron, presence: true
    validates :policy_index, presence: true
  end
end
