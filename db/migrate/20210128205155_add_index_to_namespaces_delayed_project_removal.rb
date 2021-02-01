# frozen_string_literal: true

class AddIndexToNamespacesDelayedProjectRemoval < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'tmp_idx_on_namespaces_delayed_project_removal'

  disable_ddl_transaction!

  def up
    add_concurrent_index :namespaces, :delayed_project_removal, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :namespaces, INDEX_NAME
  end
end
