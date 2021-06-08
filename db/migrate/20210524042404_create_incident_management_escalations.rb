# frozen_string_literal: true

class CreateIncidentManagementEscalations < ActiveRecord::Migration[6.0]
  def change
    create_table :incident_management_alert_escalations do |t|
      t.references :policy, index: true, null: false, foreign_key: { to_table: :incident_management_escalation_policies, on_delete: :cascade }
      t.references :alert, index: true, null: false, foreign_key: { to_table: :alert_management_alerts, on_delete: :cascade }
      t.datetime_with_timezone :last_notified_at, null: false
      t.timestamps_with_timezone
    end
  end
end
