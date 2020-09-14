# frozen_string_literal: true

class ScheduleSyncBlockingIssuesCount < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  BATCH_SIZE = 500
  DELAY_INTERVAL = 120.seconds.to_i
  MIGRATION = 'SyncBlockingIssuesCount'.freeze

  disable_ddl_transaction!

  class Issue < ActiveRecord::Base
    include EachBatch

    self.table_name = 'issues'
  end

  def up
    return unless Gitlab.ee?

    blocking_issues_ids = <<-SQL
      SELECT source_id AS blocking_issue_id FROM issue_links WHERE link_type = 1
        UNION
      SELECT target_id AS blocking_issue_id FROM issue_links WHERE link_type = 2
    SQL

    relation =
      Issue.where("id IN(#{blocking_issues_ids})") # rubocop:disable GitlabSecurity/SqlInjection
        .where(state_id: 1, blocking_issues_count: 0)

    queue_background_migration_jobs_by_range_at_intervals(
      relation,
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # no-op
  end
end
