# frozen_string_literal: true

class ShadowProjectColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    # TODO - break into separate migrations
    add_column :projects, :parent_id, :bigint
    add_foreign_key :projects, :projects, column: :parent_id, on_delete: :nullify

    # shadow projects are referenced from the group table
    change_column_null :projects, :namespace_id, true

    add_column :namespaces, :project_id, :bigint
    add_concurrent_index :namespaces, :project_id
    add_foreign_key :namespaces, :projects, on_delete: :nullify
  end

  def down
    remove_column :projects, :parent_id
    remove_column :namespaces, :project_id
  end
end
