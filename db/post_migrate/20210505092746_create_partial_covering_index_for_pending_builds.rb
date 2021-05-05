# frozen_string_literal: true

class CreatePartialCoveringIndexForPendingBuilds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  EXISTING_INDEX = 'index_ci_builds_runner_id_pending'
  NEW_INDEX = 'index_ci_builds_runner_id_pending_covering'

  def up
    execute "CREATE INDEX CONCURRENTLY #{NEW_INDEX} ON ci_builds (runner_id) INCLUDE (project_id, id) WHERE status = 'pending' AND type = 'Ci::Build'"
    remove_concurrent_index_by_name :ci_builds, EXISTING_INDEX
  end

  def down
    add_concurrent_index :ci_builds, :runner_id, where: "status = 'pending' AND type = 'Ci::Build'", name: EXISTING_INDEX
    remove_concurrent_index_by_name :ci_builds, NEW_INDEX
  end
end
