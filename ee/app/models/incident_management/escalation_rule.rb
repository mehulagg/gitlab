# frozen_string_literal: true

module IncidentManagement
  class EscalationRule < ApplicationRecord
    self.table_name = 'incident_management_escalation_rules'

    MAX_RULE_PER_POLICY_COUNT = 10

    belongs_to :policy, class_name: 'EscalationPolicy', inverse_of: 'rules', foreign_key: 'policy_id'
    belongs_to :oncall_schedule, class_name: 'OncallSchedule', inverse_of: 'rotations', foreign_key: 'oncall_schedule_id'
    has_many :pending_alert_escalations, class_name: 'PendingEscalations::Alert', inverse_of: :rule, foreign_key: :rule_id

    enum status: AlertManagement::Alert::STATUSES.slice(:acknowledged, :resolved)

    validates :status, presence: true
    validates :oncall_schedule, presence: true
    validates :elapsed_time_seconds,
              presence: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24.hours }

    validates :policy_id, uniqueness: { scope: [:oncall_schedule_id, :status, :elapsed_time_seconds], message: _('must have a unique schedule, status, and elapsed time') }

    validate :rules_count_not_exceeded, on: :create, if: :policy

    scope :for_project, ->(project) { where(policy: IncidentManagement::EscalationPolicy.where(project: project)) }
    scope :with_elapsed_time_over, ->(min_elapsed_time) { where(elapsed_time_seconds: min_elapsed_time..) }

    private

    def rules_count_not_exceeded
      # We need to add to the count if we aren't creating the rules at the same time as the policy.
      rules_count = policy.new_record? ? policy.rules.size : policy.rules.size + 1

      errors.add(:base, "cannot have more than #{MAX_RULE_PER_POLICY_COUNT} rules") if rules_count > MAX_RULE_PER_POLICY_COUNT
    end
  end
end
