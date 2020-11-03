# frozen_string_literal: true

class ScheduleMergeRequestCleanupSchedulesBackfill < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  CLOSED_MIGRATION = 'BackfillClosedMergeRequestCleanupSchedules'
  MERGED_MIGRATION = 'BackfillMergedMergeRequestCleanupSchedules'
  DELAY_INTERVAL = 2.minutes
  BATCH_SIZE = 10_000

  disable_ddl_transaction!

  def up
    closed = Gitlab::BackgroundMigration::BackfillMergeRequestCleanupSchedules::MergeRequest.closed

    queue_background_migration_jobs_by_range_at_intervals(
      closed,
      CLOSED_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )

    merged = Gitlab::BackgroundMigration::BackfillMergeRequestCleanupSchedules::MergeRequest.merged

    queue_background_migration_jobs_by_range_at_intervals(
      merged,
      MERGED_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # No-op
  end
end
