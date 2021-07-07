# frozen_string_literal: true

class AddNonNullConstraintForEscalationRuleOnPendingAlertEscalations < ActiveRecord::Migration[6.1]
  def up
    execute("DELETE FROM incident_management_pending_alert_escalations WHERE rule_id IS NULL")

    change_column_null :incident_management_pending_alert_escalations, :rule_id, false
  end

  def down
    change_column_null :incident_management_pending_alert_escalations, :rule_id, true
  end
end
