# frozen_string_literal: true

class ScheduleDeleteOrphanedDeployments < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'DeleteOrphanedDeployments'
  BATCH_SIZE = 1000

  disable_ddl_transaction!

  def up
    bulk_queue_background_migration_jobs_by_range(
      define_batchable_model('deployments').where('NOT EXISTS (SELECT 1 environments WHERE deployments.environment_id = environments.id)'),
      MIGRATION,
      batch_size: BATCH_SIZE
    )
  end

  def down
    delete_queued_jobs(MIGRATION)
  end
end
