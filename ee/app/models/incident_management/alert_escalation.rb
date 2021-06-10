# frozen_string_literal: true

module IncidentManagement
  class AlertEscalation < ApplicationRecord
    self.table_name = 'incident_management_alert_escalations'

    belongs_to :policy, class_name: 'EscalationPolicy', foreign_key: 'policy_id'
    belongs_to :alert, class_name: 'AlertManagement::Alert', foreign_key: 'alert_id'

    delegate :project, to: :policy

    def time_since_last_notify
      return 0 if last_notified_at.nil?

      last_notified_at - created_at
    end
  end
end
