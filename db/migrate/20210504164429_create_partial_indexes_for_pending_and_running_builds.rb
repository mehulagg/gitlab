# frozen_string_literal: true

class CreatePartialIndexesForPendingAndRunningBuilds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_PENDING = 'index_ci_builds_runner_id_pending'
  INDEX_RUNNING = 'index_ci_builds_runner_id_running'

  def up
    add_concurrent_index :ci_builds, :runner_id, where: "status::text = 'pending'::text", name: INDEX_PENDING
    add_concurrent_index :ci_builds, :runner_id, where: "status::text = 'running'::text", name: INDEX_RUNNING
  end

  def down
    remove_concurrent_index_by_name :ci_builds, INDEX_PENDING
    remove_concurrent_index_by_name :ci_builds, INDEX_RUNNING
  end
end
