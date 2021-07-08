# frozen_string_literal: true

# See the migration ScheduleMergeRequestDiffUsersBackgroundMigration for
# additional details
class RescheduleMergeRequestDiffUsersBackgroundMigration < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  BATCH_SIZE = 40_000

  MIGRATION_NAME = 'MigrateMergeRequestDiffCommitUsers'

  class MergeRequestDiff < ActiveRecord::Base
    self.table_name = 'merge_request_diffs'
  end

  def up
    start = MergeRequestDiff.minimum(:id).to_i
    max = MergeRequestDiff.maximum(:id).to_i
    delay = BackgroundMigrationWorker.minimum_interval

    while start < max
      stop = start + BATCH_SIZE

      migrate_in(delay, MIGRATION_NAME, [start, stop])

      Gitlab::Database::BackgroundMigrationJob
        .create!(class_name: MIGRATION_NAME, arguments: [start, stop])

      delay += BackgroundMigrationWorker.minimum_interval
      start += BATCH_SIZE
    end
  end

  def down
    # no-op
  end
end
