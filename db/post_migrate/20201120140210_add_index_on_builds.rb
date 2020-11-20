# frozen_string_literal: true

class AddIndexOnBuilds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_builds, %i[runner_id id], name: 'index_ci_builds_on_runner_id_and_id_desc', order: {id: :desc}
    remove_concurrent_index_by_name :ci_builds, 'index_ci_builds_on_runner_id'
  end

  def down
    add_concurrent_index :ci_builds, %i[runner_id], name: 'index_ci_builds_on_runner_id'
    remove_concurrent_index_by_name :ci_builds, 'index_ci_builds_on_runner_id_and_id_desc'
  end
end
