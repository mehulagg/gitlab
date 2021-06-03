# frozen_string_literal: true

class AddIndexForDraftFieldOnMergeRequests < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = "index_merge_requests_on_target_project_id_and_draft"

  disable_ddl_transaction!

  def up
    add_concurrent_index :merge_requests, [:target_project_id, :draft], name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name(:merge_requests, INDEX_NAME)
  end
end
