# frozen_string_literal: true

class AddIndexToIssuesUpvotesCount < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_issues_on_upvotes_count'
  MIGRATION = 'BackfillUpvotesCountOnIssues'
  DELAY_INTERVAL = 1.minute
  BATCH_SIZE = 50_000

  def up
    add_concurrent_index :issues, :upvotes_count, name: INDEX_NAME

    queue_background_migration_jobs_by_range_at_intervals(
      Issue,
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    remove_concurrent_index :issues, :upvotes_count, name: INDEX_NAME
  end
end
