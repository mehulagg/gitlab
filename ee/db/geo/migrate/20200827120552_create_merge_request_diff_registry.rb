# frozen_string_literal: true

class CreateMergeRequestDiffRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:merge_request_diff_registry)
      ActiveRecord::Base.transaction do
        create_table(:merge_request_diff_registry) do |t|
          t.datetime_with_timezone :created_at, null: false
          t.datetime_with_timezone :retry_at
          t.datetime_with_timezone :last_synced_at
          t.bigint :merge_request_diff_id, null: false
          t.integer :state, default: 0, null: false, limit: 2
          t.integer :retry_count, default: 0, limit: 2
          t.text :last_sync_failure

          t.index :merge_request_diff_id, name: :index_merge_request_diff_registry_on_mr_diff_id
          t.index :retry_at
          t.index :state
        end
      end
    end

    add_text_limit :merge_request_diff_registry, :last_sync_failure, 255
  end

  def down
    drop_table :merge_request_diff_registry
  end
end
