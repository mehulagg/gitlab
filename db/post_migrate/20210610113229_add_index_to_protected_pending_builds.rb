# frozen_string_literal: true

class AddIndexToProtectedPendingBuilds < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  INDEX_NAME = 'index_ci_pending_builds_on_protected'

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_pending_builds, :protected, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :ci_pending_builds, INDEX_NAME
  end
end
