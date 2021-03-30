# frozen_string_literal: true

class ScheduleBackfillTraversalIdsCom < ActiveRecord::Migration[6.0]

  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 500
  DELAY_INTERVAL = 2.minutes

  disable_ddl_transaction!

  def up
    return unless Gitlab.com?

    # Personal namespaces and top-level groups
    queue_background_migration_jobs_by_range_at_intervals(
      Namespace,
      'Gitlab::BackgroundMigration::BackfillTopLevelTraversalIds',
      DELAY_INTERVAL,
      BATCH_SIZE,
      track: true
    )

    # Subgroups
    initial_delay = (Namespace.count / BATCH_SIZE.to_f).ceil * DELAY_INTERVAL
    queue_background_migration_jobs_by_range_at_intervals(
      Namespace,
      'Gitlab::BackgroundMigration::BackfillTraversalIds',
      DELAY_INTERVAL,
      BATCH_SIZE,
      initial_delay: initial_delay,
      track: true
    )
  end
end
