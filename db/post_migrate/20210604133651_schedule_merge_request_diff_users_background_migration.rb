# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ScheduleMergeRequestDiffUsersBackgroundMigration < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  class MergeRequestDiff < ActiveRecord::Base
    include EachBatch

    self.table_name = 'merge_request_diffs'
  end

  def up
    # This table is really large, so we need a large batch size to process rows
    # in a timely fashion.
    queue_background_migration_jobs_by_range_at_intervals(
      MergeRequestDiff,
      'MigrateMergeRequestDiffCommitUsers',
      1.minute,
      batch_size: 10_000
    )
  end

  def down
    # no-op
  end
end
