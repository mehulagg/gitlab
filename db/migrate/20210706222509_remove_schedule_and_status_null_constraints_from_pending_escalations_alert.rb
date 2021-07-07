# frozen_string_literal: true

class RemoveScheduleAndStatusNullConstraintsFromPendingEscalationsAlert < ActiveRecord::Migration[6.1]
  # In preparation of removal of these columns in 14.2.
  def change
    change_column_null :incident_management_pending_alert_escalations, :status, true
    change_column_null :incident_management_pending_alert_escalations, :schedule_id, true
  end
end
