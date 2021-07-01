# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class Alert < ApplicationRecord
      include PartitionedTable
      include EachBatch

      alias_attribute :target, :alert

      self.primary_key = :id
      self.table_name = 'incident_management_pending_alert_escalations'

      ESCALATION_BUFFER = 1.month.freeze

      partitioned_by :process_at, strategy: :monthly

      belongs_to :oncall_schedule, class_name: 'OncallSchedule', foreign_key: 'schedule_id'
      belongs_to :alert, class_name: 'AlertManagement::Alert', foreign_key: 'alert_id', inverse_of: :pending_escalations
      belongs_to :rule, class_name: 'EscalationRule', foreign_key: 'rule_id', optional: true

      scope :processable, -> { where(process_at: ESCALATION_BUFFER.ago..Time.current) }

      enum status: AlertManagement::Alert::STATUSES.slice(:acknowledged, :resolved)

      validates :process_at, presence: true
      validates :status, presence: true
      validates :rule_id, presence: true, uniqueness: { scope: [:alert_id] }

      delegate :project, to: :alert
      delegate :policy, to: :rule, allow_nil: true
    end
  end
end
