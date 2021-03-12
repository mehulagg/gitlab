# frozen_string_literal: true

class ChangeLfsObjectRegistryLastSyncFailureToString < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_column(:lfs_object_registry, :last_sync_failure)

    # rubocop:disable Migration/PreventStrings
    # Changing type from text to string because the Geo schema.rb does not
    # support text limit contraints, and therefore if we don't do this, then new
    # installations will have an unlimited text field. Long term, Geo needs to
    # switch to `structure.sql`.
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/324274.
    add_column(:lfs_object_registry, :last_sync_failure, :string, limit: 255)
    # rubocop:enable Migration/PreventStrings
  end

  def down
    remove_column(:lfs_object_registry, :last_sync_failure) if column_exists?(:lfs_object_registry, :last_sync_failure)
    add_column(:lfs_object_registry, :last_sync_failure, :text)
    add_text_limit(:lfs_object_registry, :last_sync_failure, 255)
  end
end
