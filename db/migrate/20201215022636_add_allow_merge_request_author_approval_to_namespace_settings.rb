# frozen_string_literal: true

class AddAllowMergeRequestAuthorApprovalToNamespaceSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :namespace_settings, :allow_merge_request_author_approval, :boolean, default: true, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :namespace_settings, :allow_merge_request_author_approval
    end
  end
end
