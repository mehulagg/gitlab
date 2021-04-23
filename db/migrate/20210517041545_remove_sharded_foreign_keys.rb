# frozen_string_literal: true

class RemoveShardedForeignKeys < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    remove_foreign_key_if_exists :projects, column: :marked_for_deletion_by_user_id
    remove_foreign_key_if_exists :issues, column: :author_id
    remove_foreign_key_if_exists :issues, column: :closed_by_id
    remove_foreign_key_if_exists :issues, column: :updated_by_id
    remove_foreign_key_if_exists :issue_assignees, :users, column: :user_id
    remove_foreign_key_if_exists :members, :users, column: :user_id
  end

  def down
    add_concurrent_foreign_key :projects, :users, column: :marked_for_deletion_by_user_id, name: "fk_25d8780d11", on_delete: :nullify
    add_concurrent_foreign_key "issues", "users", column: "author_id", name: "fk_05f1e72feb", on_delete: :nullify
    add_concurrent_foreign_key "issues", "users", column: "closed_by_id", name: "fk_c63cbf6c25", on_delete: :nullify
    add_concurrent_foreign_key "issues", "users", column: "updated_by_id", name: "fk_ffed080f01", on_delete: :nullify
    add_concurrent_foreign_key "issue_assignees", "users", column: "user_id", name: "fk_5e0c8d9154", on_delete: :cascade
    add_concurrent_foreign_key "members", "users", column: "user_id", name: "fk_2e88fb7ce9", on_delete: :cascade
  end
end
