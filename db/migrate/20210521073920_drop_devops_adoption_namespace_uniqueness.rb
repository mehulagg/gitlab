# frozen_string_literal: true

class DropDevopsAdoptionNamespaceUniqueness < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_analytics_devops_adoption_segments_on_namespace_id'
  NEW_INDEX_NAME = 'idx_analytics_devops_adoption_segments_on_namespace_id'

  def up
    add_concurrent_index :analytics_devops_adoption_segments, :namespace_id, name: NEW_INDEX_NAME
    remove_concurrent_index_by_name :analytics_devops_adoption_segments, INDEX_NAME
  end

  def down
    rename_index :analytics_devops_adoption_segments, NEW_INDEX_NAME, INDEX_NAME
  end
end
