# frozen_string_literal: true

class AddForeignKeyContainerRepositoryIdToPackagesEvents < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_packages_events_on_container_repository_id'

  def up
    add_concurrent_index(:packages_events, :container_repository_id, name: INDEX_NAME)
    add_concurrent_foreign_key(:packages_events, :container_repositories, column: :container_repository_id, on_delete: :cascade)
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists(:packages_events, column: :container_repository_id)
    end

    remove_concurrent_index_by_name(:packages_events, name: INDEX_NAME)
  end
end
