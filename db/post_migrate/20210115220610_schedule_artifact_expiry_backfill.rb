# frozen_string_literal: true

class ScheduleArtifactExpiryBackfill < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class JobArtifact < ActiveRecord::Base
    include EachBatch

    self.table_name = 'ci_job_artifacts'

    scope :without_expiry_date, -> { where(expire_at: nil) }
    scope :before_switch, -> { where('created_at < ?', SWITCH_DATE) }
  end

  def up
    queue_background_migration_jobs_by_range_at_intervals(
      JobArtifact.without_expiry_date.before_switch,
      'BackfillArtifactExpiryDate',
      2.minutes,
      batch_size: 200_000
    )
  end
end
