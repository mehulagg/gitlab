# frozen_string_literal: true

class AddApprovalGroupRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :approval_group_rules, if_not_exists: true do |t|
        t.timestamps_with_timezone
        t.references :group, references: :namespaces, index: true, null: false,
          foreign_key: { to_table: :namespaces, on_delete: :cascade }
        t.integer :approvals_required, limit: 2, null: false, default: 0
        t.integer :rule_type, limit: 2, null: false, default: 0
        t.text :name, null: false
      end
    end

    add_text_limit :approval_group_rules, :name, 255
  end

  def down
    with_lock_retries do
      drop_table :approval_group_rules
    end
  end
end
