# frozen_string_literal: true

class AddIssueCustomTypeIdToIssue < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless column_exists?(:issues, :issue_custom_type_id)
      with_lock_retries do
        add_column :issues, :issue_custom_type_id, :bigint
      end
    end

    add_concurrent_index :issues, :issue_custom_type_id
    add_concurrent_foreign_key :issues, :issue_custom_types, column: :issue_custom_type_id, on_delete: :nullify
  end

  def down
    with_lock_retries do
      remove_column :issues, :issue_custom_type_id
    end
  end
end
