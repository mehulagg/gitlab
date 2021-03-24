# frozen_string_literal: true

class CreateExternalApprovalTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table :external_approvals do |t|
      t.bigint :merge_request_id, null: false
      t.bigint :external_approval_rule_id, null: false
    end

    add_index :external_approvals, :merge_request_id
    add_index :external_approvals, :external_approval_rule_id
  end

  def down
    drop_table :external_approvals
  end
end
