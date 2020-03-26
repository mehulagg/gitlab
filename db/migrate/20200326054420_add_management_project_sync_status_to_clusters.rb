# frozen_string_literal: true

class AddManagementProjectSyncStatusToClusters < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default :clusters, :management_project_sync_status, :smallint, default: 0, allow_null: false
  end

  def down
    remove_column :clusters, :management_project_sync_status
  end
end
