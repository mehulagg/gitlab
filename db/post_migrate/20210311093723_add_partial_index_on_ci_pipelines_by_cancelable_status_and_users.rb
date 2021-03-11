# frozen_string_literal: true

class AddPartialIndexOnCiPipelinesByCancelableStatusAndUsers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_ci_pipelines_on_user_id_and_id_and_cancelable_status'

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_pipelines, [:user_id, :id], where: "status IN ('running', 'waiting_for_resource', 'preparing', 'pending', 'created', 'scheduled')", name: INDEX_NAME
  end

  def down
    remove_concurrent_index :ci_pipelines, [:user_id, :id], name: INDEX_NAME
  end
end
