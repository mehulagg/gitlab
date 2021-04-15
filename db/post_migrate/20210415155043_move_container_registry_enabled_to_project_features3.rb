# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MoveContainerRegistryEnabledToProjectFeatures3 < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  BATCH_SIZE = 21_000
  MIGRATION = 'MoveContainerRegistryEnabledToProjectFeature'

  disable_ddl_transaction!

  class Project < ActiveRecord::Base
    include EachBatch
    self.table_name = 'projects'
  end

  def up
    delete_queued_jobs('MoveContainerRegistryEnabledToProjectFeature')

    ::Gitlab::Database::BackgroundMigrationJob.for_migration_class(MIGRATION).delete_all

    queue_background_migration_jobs_by_range_at_intervals(Project, MIGRATION, 2.minutes, batch_size: BATCH_SIZE, track_jobs: true)
  end

  def down
    # no-op
  end
end
