# frozen_string_literal: true

class ExampleBackgroundMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION_JOB_NAME = 'Gitlab::BackgroundMigration::CopyColumnUsingBackgroundMigrationJob'

  def up
    queue_batched_background_migration MIGRATION_JOB_NAME, :events, :id, job_interval: 2.minutes,
      batch_max_value: 400, batch_size: 100, sub_batch_size: 10
  end

  def down
    abort_batched_background_migration MIGRATION_JOB_NAME
  end
end
