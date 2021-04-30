# frozen_string_literal: true

class AddDevopsAdoptionIndexes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  SEGMENTS_INDEX_NAME = 'idx_devops_adoption_segments_namespaces_pair'.freeze
  SNAPSHOT_END_TIME_INDEX_NAME = 'idx_devops_adoption_segments_namespace_end_time'.freeze
  SNAPSHOT_RECORDED_AT_INDEX_NAME = 'idx_devops_adoption_segments_namespace_recorded_at'.freeze

  def up
    add_concurrent_index :analytics_devops_adoption_snapshots, [:namespace_id, :end_time],
                         name: SNAPSHOT_END_TIME_INDEX_NAME
    add_concurrent_index :analytics_devops_adoption_snapshots, [:namespace_id, :recorded_at],
                         name: SNAPSHOT_RECORDED_AT_INDEX_NAME
    add_concurrent_index :analytics_devops_adoption_segments, [:display_namespace_id, :namespace_id],
                         unique: true, name: SEGMENTS_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :analytics_devops_adoption_segments, SEGMENTS_INDEX_NAME
    remove_concurrent_index_by_name :analytics_devops_adoption_snapshots, SNAPSHOT_END_TIME_INDEX_NAME
    remove_concurrent_index_by_name :analytics_devops_adoption_snapshots, SNAPSHOT_RECORDED_AT_INDEX_NAME
  end
end
