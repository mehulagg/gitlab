# frozen_string_literal: true

class CreateIncidentManagementIssuableEscalationStatuses < ActiveRecord::Migration[6.1]
  DOWNTIME = false
  IDX = 'idx_im_issuable_escalation_statuses_on_issue_id'

  def change
    create_table :incident_management_issuable_escalation_statuses do |t|
      t.references :issue, foreign_key: { on_delete: :cascade }, index: { unique: true, name: IDX }, null: false
      t.integer :status, default: 0, null: false, limit: 2
    end
  end
end
