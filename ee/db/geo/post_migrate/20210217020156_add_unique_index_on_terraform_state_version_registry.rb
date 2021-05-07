# frozen_string_literal: true

class AddUniqueIndexOnTerraformStateVersionRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_tf_state_versions_registry_on_tf_state_versions_id'
  NEW_INDEX_NAME = 'index_tf_state_versions_registry_tf_state_versions_id_unique'

  disable_ddl_transaction!

  def up
    # Removing duplicated records that would prevent creating an unique index.
    execute <<-SQL
      DELETE FROM terraform_state_version_registry
      USING (
        SELECT terraform_state_version_id, MIN(id) as min_id
        FROM terraform_state_version_registry
        GROUP BY terraform_state_version_id
        HAVING COUNT(id) > 1
      ) as terraform_state_version_registry_duplicates
      WHERE terraform_state_version_registry_duplicates.terraform_state_version_id = terraform_state_version_registry.terraform_state_version_id
      AND terraform_state_version_registry_duplicates.min_id <> terraform_state_version_registry.id
    SQL

    add_concurrent_index(:terraform_state_version_registry,
                         :terraform_state_version_id,
                         unique: true,
                         name: NEW_INDEX_NAME)

    remove_concurrent_index_by_name :terraform_state_version_registry, OLD_INDEX_NAME
  end

  def down
    add_concurrent_index(:terraform_state_version_registry,
                         :terraform_state_version_id,
                         name: OLD_INDEX_NAME)

    remove_concurrent_index_by_name :terraform_state_version_registry, NEW_INDEX_NAME
  end
end
