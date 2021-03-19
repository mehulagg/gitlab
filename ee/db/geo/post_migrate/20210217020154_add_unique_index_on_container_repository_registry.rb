# frozen_string_literal: true

class AddUniqueIndexOnContainerRepositoryRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_container_repository_registry_on_repository_id'
  NEW_INDEX_NAME = 'index_container_repository_registry_repository_id_unique'

  disable_ddl_transaction!

  def up
    # Removing duplicated records that would prevent creating an unique index.
    execute <<-SQL
      DELETE FROM container_repository_registry
      USING (
        SELECT container_repository_id, MIN(id) as min_id
        FROM container_repository_registry
        GROUP BY container_repository_id
        HAVING COUNT(id) > 1
      ) as container_repository_registry_duplicates
      WHERE container_repository_registry_duplicates.container_repository_id = container_repository_registry.container_repository_id
      AND container_repository_registry_duplicates.min_id <> container_repository_registry.id
    SQL

    add_concurrent_index(:container_repository_registry,
                         :container_repository_id,
                         unique: true,
                         name: NEW_INDEX_NAME)

    remove_concurrent_index_by_name :container_repository_registry, OLD_INDEX_NAME
  end

  def down
    add_concurrent_index(:container_repository_registry,
                         :container_repository_id,
                         name: OLD_INDEX_NAME)

    remove_concurrent_index_by_name :container_repository_registry, NEW_INDEX_NAME
  end
end
