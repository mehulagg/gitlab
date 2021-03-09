# frozen_string_literal: true

class AddIndexToDastProfileIdOnCiPipeline < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = :index_ci_pipelines_on_dast_profile_id

  def up
    add_concurrent_index :ci_pipelines, :dast_profile_id, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :ci_pipelines, :dast_profile_id, name: INDEX_NAME
  end
end
