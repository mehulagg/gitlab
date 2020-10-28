# frozen_string_literal: true

class BackfillJiraTrackerDeploymentType2 < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  MIGRATION = 'BackfillJiraTrackerDeploymentType'
  DELAY_INTERVAL = 2.minutes
  BATCH_SIZE = 10_000

  disable_ddl_transaction!

  class JiraTrackerData < ActiveRecord::Base
    include EachBatch

    self.table_name = 'jira_tracker_data'
  end

  def up
    say "Scheduling `#{MIGRATION}` jobs"

    queue_background_migration_jobs_by_range_at_intervals(
      JiraTrackerData.where(deployment_type: 0),
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE)
  end

  def down
    # NOOP
  end
end
