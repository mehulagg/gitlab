# frozen_string_literal: true

class AddNamespaceIdToCiPendingBuild < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :ci_pending_builds, :namespace_id, :bigint
    end
  end

  def down
    with_lock_retries do
      remove_column :ci_pending_builds, :namespace_id
    end
  end
end
