# frozen_string_literal: true

class AddLfsObjectStateIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = 'index_state_in_lfs_objects'

  disable_ddl_transaction!

  def up
    add_concurrent_index :lfs_object_registry, :state, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :lfs_object_registry, :state, name: INDEX_NAME
  end
end
