# frozen_string_literal: true

class ShadowProjectColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    # TODO - break into separate migrations
    add_column :projects, :parent_id, :bigint
    add_foreign_key :projects, :projects, column: :parent_id, on_delete: :nullify

    # TODO: we would have to make sure we don't expose shadowed projects anywhere
    # another approach would be allow NULL group_id for shadowed projects and reference
    # them from group table (but this introduces an inconsistency and makes preloading harder)
    add_column :projects, :shadow, :boolean, default: false
    add_concurrent_index :projects, [:namespace_id, :shadow]
  end

  def down
    remove_column :projects, :parent_id
    remove_column :projects, :shadow
  end
end
