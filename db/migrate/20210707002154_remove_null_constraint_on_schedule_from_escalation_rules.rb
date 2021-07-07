# frozen_string_literal: true

class RemoveNullConstraintOnScheduleFromEscalationRules < ActiveRecord::Migration[6.1]
  def change
    change_column_null :incident_management_escalation_rules, :oncall_schedule_id, true
  end
end
