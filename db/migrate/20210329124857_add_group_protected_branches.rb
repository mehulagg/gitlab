# frozen_string_literal: true

class AddGroupProtectedBranches < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :group_protected_branches, if_not_exists: true do |t|
        t.timestamps_with_timezone
        t.references :group, references: :namespaces, index: true, null: false,
          foreign_key: { to_table: :namespaces, on_delete: :cascade }
        t.boolean :code_owner_approval_required, null: false, default: false
        t.boolean :allow_force_push, null: false, default: false
        t.text :name, null: false
      end
    end

    add_text_limit :group_protected_branches, :name, 255
  end

  def down
    with_lock_retries do
      drop_table :group_protected_branches
    end
  end
end
