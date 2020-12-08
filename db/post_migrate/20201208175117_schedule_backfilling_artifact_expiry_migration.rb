# frozen_string_literal: true

class ScheduleBackfillingArtifactExpiryMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'expired_artifacts_temp_index'
  INDEX_CONDITION = 'expire_at IS NULL'

  disable_ddl_transaction!

  def up
    # Create temporary index for expired artifacts
    # Needs to be removed in a later migration
    add_concurrent_index(:ci_job_artifacts, :expire_at, where: INDEX_CONDITION, name: INDEX_NAME)

    queue_background_migration_jobs_by_range_at_intervals(
      ::Ci::JobArtifact,
      ::Gitlab::BackgroundMigration::BackfillArtifactExpiryDate,
      2.minutes,
      batch_size: 100_000
    )
  end

  def down
    # no-op
  end
end
