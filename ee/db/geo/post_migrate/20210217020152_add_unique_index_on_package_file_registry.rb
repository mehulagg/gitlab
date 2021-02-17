# frozen_string_literal: true

class AddUniqueIndexOnPackageFileRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_package_file_registry_on_repository_id'
  NEW_INDEX_NAME = 'unique_index_package_file_registry_on_package_file_id'

  disable_ddl_transaction!

  def up
    # Removing duplicated records that would prevent re-creating the old index.
    execute <<-SQL
      DELETE FROM package_file_registry
      USING (
        SELECT package_file_id, MIN(id) as min_id
        FROM package_file_registry
        GROUP BY package_file_id
        HAVING COUNT(id) > 1
      ) as package_file_registry_duplicates
      WHERE package_file_registry_duplicates.package_file_id = package_file_registry.package_file_id
      AND package_file_registry_duplicates.min_id <> package_file_registry.id
    SQL

    add_concurrent_index(:package_file_registry,
                         :package_file_id,
                         unique: true,
                         name: NEW_INDEX_NAME)

    remove_concurrent_index_by_name :package_file_registry, OLD_INDEX_NAME
  end

  def down
    add_concurrent_index(:package_file_registry,
                         :package_file_id,
                         name: OLD_INDEX_NAME)

    remove_concurrent_index_by_name :package_file_registry, NEW_INDEX_NAME
  end
end
