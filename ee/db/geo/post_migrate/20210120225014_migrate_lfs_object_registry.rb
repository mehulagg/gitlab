# frozen_string_literal: true

class MigrateLfsObjectRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  TABLE_NAME = :lfs_object_registry

  disable_ddl_transaction!

  def up
    add_not_null_constraint TABLE_NAME, :lfs_object_id, validate: false
    add_not_null_constraint TABLE_NAME, :created_at, validate: false
    change_column_default TABLE_NAME, :retry_count, from: nil, to: 0
    change_column TABLE_NAME, :retry_count, :integer, limit: 2
    add_column TABLE_NAME, :state, :integer, null: false, limit: 2, default: 0
    add_column TABLE_NAME, :last_synced_at, :datetime_with_timezone
    add_column TABLE_NAME, :last_sync_failure, :text

    add_text_limit TABLE_NAME, :last_sync_failure, 255
  end

  def down
    remove_not_null_constraint TABLE_NAME, :lfs_object_id
    remove_not_null_constraint TABLE_NAME, :created_at
    change_column_default TABLE_NAME, :retry_count, from: 0, to: nil
    change_column TABLE_NAME, :retry_count, :integer, limit: nil
    remove_column TABLE_NAME, :state
    remove_column TABLE_NAME, :last_synced_at
    remove_column TABLE_NAME, :last_sync_failure
  end
end
