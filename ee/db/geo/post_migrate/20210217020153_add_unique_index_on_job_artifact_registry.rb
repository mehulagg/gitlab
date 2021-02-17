# frozen_string_literal: true

class AddUniqueIndexOnJobArtifactRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_job_artifact_registry_on_artifact_id'
  NEW_INDEX_NAME = 'unique_index_job_artifact_registry_on_artifact_id'

  disable_ddl_transaction!

  def up
    # Removing duplicated records that would prevent re-creating the old index.
    execute <<-SQL
      DELETE FROM job_artifact_registry
      USING (
        SELECT artifact_id, MIN(id) as min_id
        FROM job_artifact_registry
        GROUP BY artifact_id
        HAVING COUNT(id) > 1
      ) as job_artifact_registry_duplicates
      WHERE job_artifact_registry_duplicates.artifact_id = job_artifact_registry.artifact_id
      AND job_artifact_registry_duplicates.min_id <> job_artifact_registry.id
    SQL

    add_concurrent_index(:job_artifact_registry,
                         :artifact_id,
                         unique: true,
                         name: NEW_INDEX_NAME)

    remove_concurrent_index_by_name :job_artifact_registry, OLD_INDEX_NAME
  end

  def down
    add_concurrent_index(:job_artifact_registry,
                         :artifact_id,
                         name: OLD_INDEX_NAME)

    remove_concurrent_index_by_name :job_artifact_registry, NEW_INDEX_NAME
  end
end
