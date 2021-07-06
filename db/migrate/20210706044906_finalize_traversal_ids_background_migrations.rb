# frozen_string_literal: true

class FinalizeTraversalIdsBackgroundMigrations < ActiveRecord::Migration[6.1]
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    Gitlab::BackgroundMigration.steal('BackfillNamespaceTraversalIdsRoots')
    Gitlab::BackgroundMigration.steal('BackfillNamespaceTraversalIdsChildren')

    Gitlab::Database::BackgroundMigrationJob
      .where(status: Gitlab::Database::BackgroundMigrationJob.statuses['succeeded'])
      .delete_all
  end

  def down
    # no-op
  end
end
