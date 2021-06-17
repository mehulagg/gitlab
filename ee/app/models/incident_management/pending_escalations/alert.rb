# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class Alert < ApplicationRecord
      include PartitionedTable
      alias_attribute :target, :alert

      self.primary_key = :id
      self.table_name = 'incident_management_pending_alert_escalations'

      partitioned_by :process_at, strategy: :monthly

      belongs_to :oncall_schedule, class_name: 'OncallSchedule', foreign_key: 'schedule_id'
      belongs_to :alert, class_name: 'AlertManagement::Alert', foreign_key: 'alert_id'
      belongs_to :rule, class_name: 'EscalationRule', foreign_key: 'rule_id', optional: true

      enum status: AlertManagement::Alert::STATUSES.slice(:acknowledged, :resolved)

      validates :process_at, presence: true
      validates :status, presence: true

      delegate :project, to: :oncall_schedule
    end
  end
end
