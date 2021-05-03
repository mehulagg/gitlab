# frozen_string_literal: true

class AddFkToProjectValueStreamId < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  CONSTRAINT_NAME = 'fk_analytics_cycle_analytics_project_stages_project_value_stream_id'
  INDEX_NAME = 'index_analytics_ca_project_stages_on_value_stream_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :analytics_cycle_analytics_project_stages, :project_value_stream_id, name: INDEX_NAME
    add_concurrent_foreign_key :analytics_cycle_analytics_project_stages, :projects, column: :project_value_stream_id, on_delete: :cascade
  end

  def down
    remove_foreign_key_if_exists :analytics_cycle_analytics_project_stages, column: :project_value_stream_id, name: CONSTRAINT_NAME
    remove_concurrent_index_by_name :analytics_cycle_analytics_project_stages, :project_value_stream_id
  end
end
