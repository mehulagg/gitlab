# frozen_string_literal: true

class CreateIncidentManagementIssueEscalationStatuses < ActiveRecord::Migration[6.1]
  DOWNTIME = false
  ISSUE_IDX = 'index_im_issue_escalation_statuses_on_issue_id'
  POLICY_IDX = 'index_im_issue_escalation_statuses_on_policy_id'

  def change
    create_table :incident_management_issue_escalation_statuses do |t|
      t.references :issue, foreign_key: { on_delete: :cascade }, index: { unique: true, name: ISSUE_IDX }, null: false
      t.references :policy, foreign_key: { to_table: :incident_management_escalation_policies, on_delete: :nullify }, index: { name: POLICY_IDX }
      t.integer :status, default: 0, null: false, limit: 2
    end
  end
end
