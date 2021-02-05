# frozen_string_literal: true

class MigrateLfsObjectRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_not_null_constraint :lfs_object_registry, :lfs_object_id, validate: false
    add_not_null_constraint :lfs_object_registry, :created_at, validate: false
    change_column_default :lfs_object_registry, :retry_count, from: nil, to: 0
    add_column :lfs_object_registry, :state, :integer, null: false, limit: 2, default: 0
    add_column :lfs_object_registry, :last_synced_at, :datetime_with_timezone
    add_column :lfs_object_registry, :last_sync_failure, :text
    add_text_limit :lfs_object_registry, :last_sync_failure, 255
  end

  def down
    remove_not_null_constraint :lfs_object_registry, :lfs_object_id
    remove_not_null_constraint :lfs_object_registry, :created_at
    change_column_default :lfs_object_registry, :retry_count, from: 0, to: nil
    remove_column :lfs_object_registry, :state
    remove_column :lfs_object_registry, :last_synced_at
    remove_column :lfs_object_registry, :last_sync_failure
  end
end
