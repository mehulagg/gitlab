# frozen_string_literal: true

class RenameGroupIdToNamespaceIdInEpics < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    rename_column_concurrently :epics, :group_id, :namespace_id
    cleanup_concurrent_column_rename :epics, :group_id, :namespace_id
  end

  def down
    # undo_rename_column_concurrently :epics, :group_id, :namespace_id
    remove_column :epics, :namespace_id
  end
end
