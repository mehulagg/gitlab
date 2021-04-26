# frozen_string_literal: true

class ReOrderFkSourceProjectIdInMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_foreign_key_if_exists :merge_requests, column: :source_project_id

      add_foreign_key_if_not_exists :merge_requests, :projects, column: :source_project_id, on_delete: :nullify
    end
  end
end
