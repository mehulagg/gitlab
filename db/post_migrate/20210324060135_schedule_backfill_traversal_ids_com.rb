# frozen_string_literal: true

class ScheduleBackfillTraversalIdsCom < ActiveRecord::Migration[6.0]

  include Gitlab::Database::MigrationHelpers

  ROOTS_MIGRATION = 'BackfillTraversalIds::BackfillRoots'
  CHILDREN_MIIGRATION = 'BackfillTraversalIds::BackfillChildren'
  DOWNTIME = false
  BATCH_SIZE = 500
  SUB_BATCH_SIZE = 100
  DELAY_INTERVAL = 2.minutes

  disable_ddl_transaction!

  def up
    return unless Gitlab.com?

    # Personal namespaces and top-level groups
    queue_background_migration_jobs_by_range_at_intervals(
      BackfillTraversalIds::BackfillRoots::BASE_QUERY,
      ROOTS_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      other_job_arguments: [SUB_BATCH_SIZE],
      track_jobs: true
    )

    # Subgroups
    initial_delay = (Namespace.count / BATCH_SIZE.to_f).ceil * DELAY_INTERVAL
    queue_background_migration_jobs_by_range_at_intervals(
      BackfillTraversalIds::BackfillChildren::BASE_QUERY,
      CHILDREN_MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      initial_delay: initial_delay,
      other_job_arguments: [SUB_BATCH_SIZE],
      track_jobs: true
    )
  end
end
