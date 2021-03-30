# frozen_string_literal: true

class AddApprovalGroupsRulesGroups < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :approval_group_rules_groups, if_not_exists: true do |t|
        t.references :approval_group_rules, index: true, null: false, on_delete: :cascade
        t.references :group, references: :namespaces, index: true, null: false, foreign_key: { to_table: :namespaces }
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :approval_group_rules_groups
    end
  end
end
