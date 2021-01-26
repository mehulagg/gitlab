# frozen_string_literal: true

class MigrateLfsObjectRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    table_name = :lfs_object_registry

    change_column_null table_name, :lfs_object_id, false
    change_column_null table_name, :created_at, false
    change_column_default table_name, :retry_count, 0
    change_column table_name, :retry_count, :integer, limit: 2
    add_column table_name, :state, :integer, null: false, limit: 2, default: 0
    add_column table_name, :last_synced_at, :datetime_with_timezone
    add_column table_name, :last_sync_failure, :text
    add_text_limit table_name, :last_sync_failure, 255
  end
end
