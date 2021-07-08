# frozen_string_literal: true

class BackfillProjectSearchTokens < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  MIGRATION = 'BackfillProjectSearchTokens'
  DELAY_INTERVAL = 2.minutes
  BATCH_SIZE = 10_000

  def up
    queue_background_migration_jobs_by_range_at_intervals(
      Project.all,
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # no-op
  end
end
