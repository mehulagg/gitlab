# frozen_string_literal: true

class AddPipelinesCreatedIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_pipelines, [:project_id, :status, :created_at]
  end

  def down
    remove_concurrent_index_by_name :ci_pipelines, :index_ci_pipelines_on_project_id_and_status_and_created_at
  end
end
