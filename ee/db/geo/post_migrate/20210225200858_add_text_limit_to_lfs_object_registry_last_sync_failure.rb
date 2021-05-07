# frozen_string_literal: true

class AddTextLimitToLfsObjectRegistryLastSyncFailure < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :lfs_object_registry, :last_sync_failure, 255
  end

  def down
    remove_text_limit :lfs_object_registry, :last_sync_failure
  end
end
