# frozen_string_literal: true

class SchedulePopulateIssueEmailParticipants < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 100_000
  DELAY_INTERVAL = 2.minutes
  MIGRATION = Gitlab::BackgroundMigration::PopulateIssueEmailParticipants
  MIGRATION_NAME = MIGRATION.to_s.demodulize

  disable_ddl_transaction!

  class Issue < ActiveRecord::Base
    include EachBatch

    self.table_name = 'issues'
  end

  def up
    queue_background_migration_jobs_by_range_at_intervals(
      Issue.where.not(service_desk_reply_to: nil),
      MIGRATION_NAME,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # no-op
  end
end
