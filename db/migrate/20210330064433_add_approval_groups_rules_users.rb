# frozen_string_literal: true

class AddApprovalGroupsRulesUsers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :approval_group_rules_users, if_not_exists: true do |t|
        t.references :approval_group_rules, index: true, null: false, on_delete: :cascade
        t.references :users, index: true, null: false, on_delete: :cascade
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :approval_group_rules_users
    end
  end
end
