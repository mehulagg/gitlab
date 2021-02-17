# frozen_string_literal: true

class AddUniqueIndexOnMergeRequestDiffRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  OLD_INDEX_NAME = 'index_merge_request_diff_registry_on_mr_diff_id'
  NEW_INDEX_NAME = 'unique_index_merge_request_diff_registry_on_mr_diff_id'

  disable_ddl_transaction!

  def up
    # Removing duplicated records that would prevent re-creating the old index.
    execute <<-SQL
      DELETE FROM merge_request_diff_registry
      USING (
        SELECT merge_request_diff_id, MIN(id) as min_id
        FROM merge_request_diff_registry
        GROUP BY merge_request_diff_id
        HAVING COUNT(id) > 1
      ) as merge_request_diff_registry_duplicates
      WHERE merge_request_diff_registry_duplicates.merge_request_diff_id = merge_request_diff_registry.merge_request_diff_id
      AND merge_request_diff_registry_duplicates.min_id <> merge_request_diff_registry.id
    SQL

    add_concurrent_index(:merge_request_diff_registry,
                         :merge_request_diff_id,
                         unique: true,
                         name: NEW_INDEX_NAME)

    remove_concurrent_index_by_name :merge_request_diff_registry, OLD_INDEX_NAME
  end

  def down
    add_concurrent_index(:merge_request_diff_registry,
                         :merge_request_diff_id,
                         name: OLD_INDEX_NAME)

    remove_concurrent_index_by_name :merge_request_diff_registry, NEW_INDEX_NAME
  end
end
