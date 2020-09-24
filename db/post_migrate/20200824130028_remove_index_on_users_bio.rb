# frozen_string_literal: true

class RemoveIndexOnUsersBio < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BACKGROUND_MIGRATION_CLASS = 'MigrateUsersBioToUserDetails'
  INDEX_NAME = 'tmp_idx_on_user_id_where_bio_is_filled'

  disable_ddl_transaction!

  def up
    Gitlab::BackgroundMigration.steal(BACKGROUND_MIGRATION_CLASS)
    remove_concurrent_index_by_name(:users, INDEX_NAME)
  end

  def down
    add_concurrent_index :users, :id, where: "(COALESCE(bio, '') IS DISTINCT FROM '')", name: INDEX_NAME
  end
end
