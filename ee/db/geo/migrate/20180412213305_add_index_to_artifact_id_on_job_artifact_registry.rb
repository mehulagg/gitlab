# frozen_string_literal: true

class AddIndexToArtifactIdOnJobArtifactRegistry < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :job_artifact_registry, :artifact_id
  end

  def down
    if index_exists?(:job_artifact_registry, :artifact_id)
      remove_concurrent_index :job_artifact_registry_finder, :artifact_id
    end
  end
end
