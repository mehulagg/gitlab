# frozen_string_literal: true

class MigrateLfsObjectRegistry < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column_default :lfs_object_registry, :retry_count, from: nil, to: 0
    add_column :lfs_object_registry, :state, :integer, null: false, limit: 2, default: 0
    add_column :lfs_object_registry, :last_synced_at, :datetime_with_timezone
    # rubocop:disable Migration/AddLimitToTextColumns
    # limit is added in 20210225200858_add_text_limit_to_lfs_object_registry_last_sync_failure
    add_column :lfs_object_registry, :last_sync_failure, :text
    # rubocop:enable Migration/AddLimitToTextColumns
  end

  def down
    change_column_default :lfs_object_registry, :retry_count, from: 0, to: nil
    remove_column :lfs_object_registry, :state
    remove_column :lfs_object_registry, :last_synced_at
    remove_column :lfs_object_registry, :last_sync_failure
  end
end
