# frozen_string_literal: true

module IncidentManagement
  class EscalationRule < ApplicationRecord
    self.table_name = 'incident_management_escalation_rules'

    belongs_to :policy, class_name: 'EscalationPolicy', inverse_of: 'rules', foreign_key: 'policy_id'
    belongs_to :oncall_schedule, class_name: 'OncallSchedule', inverse_of: 'rotations', foreign_key: 'oncall_schedule_id'

    enum status: AlertManagement::Alert::STATUSES.slice(:acknowledged, :resolved)

    validates :status, presence: true
    validates :oncall_schedule, presence: true
    validates :elapsed_time_seconds,
              presence: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 24.hours }

    validates :policy_id, uniqueness: { scope: [:oncall_schedule_id, :status, :elapsed_time_seconds], message: _('Must have a unique policy, status, and elapsed time') }

    validate :oncall_schedule_same_project_as_policy

    private

    def oncall_schedule_same_project_as_policy
      return unless oncall_schedule_id

      return if oncall_schedule.project_id == policy.project_id

      errors.add(:oncall_schedule_id, _('Schedule must be from the same project as the policy'))
    end
  end
end
