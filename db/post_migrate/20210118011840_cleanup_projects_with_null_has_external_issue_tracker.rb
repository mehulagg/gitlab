# frozen_string_literal: true

class CleanupProjectsWithNullHasExternalIssueTracker < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  # On GitLab.com there will be ~350 projects updated, however, we use
  # batching out of abundant caution.
  BATCH_SIZE = 1000

  disable_ddl_transaction!

  class Service < ActiveRecord::Base
    self.table_name = 'services'
  end

  class Project < ActiveRecord::Base
    include EachBatch

    self.table_name = 'projects'
  end

  def up
    services_sub_query = Service
      .select('1')
      .where('services.project_id = projects.id')
      .where(category: 'issue_tracker')
      .where(active: true)

    Project.each_batch(of: BATCH_SIZE) do |relation|
      # 11 projects are scoped in this query on GitLab.com.
      # Expected run time ~130 ms (cold cache query).
      relation
        .where('EXISTS (?)', services_sub_query)
        .where(has_external_issue_tracker: [false, nil]) # By additionally scoping `false` we also correct historic bad data: https://gitlab.com/gitlab-org/gitlab/-/issues/273574
        .where(pending_delete: false)
        .where(archived: false)
        .update_all(has_external_issue_tracker: true)

      # 322 projects are scoped in this query on GitLab.com.
      # Expected run time ~3 minutes (cold cache query).
      relation
        .where('NOT EXISTS (?)', services_sub_query)
        .where(has_external_issue_tracker: [true, nil]) # By additionally scoping `true` we also correct historic bad data: https://gitlab.com/gitlab-org/gitlab/-/issues/273574
        .where(pending_delete: false)
        .where(archived: false)
        .update_all(has_external_issue_tracker: false)
    end
  end

  def down
    # no-op : can't go back to `NULL` without first dropping the `NOT NULL` constraint
  end
end
