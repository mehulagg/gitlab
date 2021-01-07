# frozen_string_literal: true

class AddDiffTypeToMergeRequestDiffs < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :merge_request_diffs, :diff_type, :integer, limit: 2, default: 1
    end

    add_concurrent_index :merge_request_diffs, :diff_type
  end

  def down
    remove_concurrent_index :merge_request_diffs, :diff_type

    with_lock_retries do
      remove_column :merge_request_diffs, :diff_type
    end
  end
end
