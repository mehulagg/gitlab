# frozen_string_literal: true

class RemoveDuplicateServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INTERVAL = 2.minutes
  BATCH_SIZE = 5000
  MIGRATION = 'RemoveDuplicateServices'

  disable_ddl_transaction!

  def up
    projects_with_services = Gitlab::BackgroundMigration::RemoveDuplicateServices::Project.with_services

    queue_background_migration_jobs_by_range_at_intervals(
      projects_with_services,
      MIGRATION,
      INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
  end
end
