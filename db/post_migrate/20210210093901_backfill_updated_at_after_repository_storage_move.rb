# frozen_string_literal: true

class BackfillUpdatedAtAfterRepositoryStorageMove < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 10_000
  INTERVAL = 5.minutes
  MIGRATION_CLASS = 'BackfillProjectUpdatedAtAfterRepositoryStorageMove'

  disable_ddl_transaction!

  class ProjectRepositoryStorageMove < ActiveRecord::Base
    include EachBatch

    self.table_name = 'project_repository_storage_moves'
  end

  def up
    ProjectRepositoryStorageMove.reset_column_information

    relation = ProjectRepositoryStorageMove.select(:project_id).distinct

    queue_background_migration_jobs_by_range_at_intervals(
      relation,
      MIGRATION_CLASS,
      INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # No-op
  end
end
