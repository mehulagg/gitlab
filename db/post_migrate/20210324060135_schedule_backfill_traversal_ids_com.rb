# frozen_string_literal: true

class ScheduleBackfillTraversalIdsCom < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  ROOTS_MIGRATION = 'BackfillNamespaceTraversalIdsRoots'
  CHILDREN_MIGRATION = 'BackfillNamespaceTraversalIdsChildren'
  DOWNTIME = false
  BATCH_SIZE = 1_000
  SUB_BATCH_SIZE = 100
  DELAY_INTERVAL = 2.minutes

  disable_ddl_transaction!

  def up
    # Personal namespaces and top-level groups
    final_delay = queue_background_migration_jobs_by_range_at_intervals(
      ::Gitlab::BackgroundMigration::BackfillNamespaceTraversalIdsRoots.base_query,
      ROOTS_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      other_job_arguments: [SUB_BATCH_SIZE],
      track_jobs: false
    )
    final_delay += DELAY_INTERVAL

    # Subgroups
    queue_background_migration_jobs_by_range_at_intervals(
      ::Gitlab::BackgroundMigration::BackfillNamespaceTraversalIdsChildren.base_query,
      CHILDREN_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      other_job_arguments: [SUB_BATCH_SIZE],
      track_jobs: false
    )
  end
end
