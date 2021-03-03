# frozen_string_literal: true

class AddConcurrentFieldsToBulkImportsTrackers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  UNIQUE_INDEX = 'unique_pipeline_per_stage_per_entity'

  disable_ddl_transaction!

  def up
    unless column_exists?(:bulk_import_failures, :pipeline_name, :text)
      with_lock_retries do
        add_column :bulk_import_trackers, :jid, :text
        add_column :bulk_import_trackers, :pipeline_name, :text
        add_column :bulk_import_trackers, :stage, :integer, null: false, limit: 2
        add_column :bulk_import_trackers, :status, :integer, null: false, limit: 2

        change_column_null :bulk_import_trackers, :relation, true
      end
    end

    add_text_limit :bulk_import_trackers, :pipeline_name, 255
    add_text_limit :bulk_import_trackers, :jid, 255

    add_concurrent_index :bulk_import_trackers,
      [:bulk_import_entity_id, :pipeline_name, :stage],
      name: UNIQUE_INDEX,
      unique: true
  end

  def down
    with_lock_retries do
      remove_column :bulk_import_trackers, :jid, :text
      remove_column :bulk_import_trackers, :pipeline_name, :text
      remove_column :bulk_import_trackers, :stage, :integer
      remove_column :bulk_import_trackers, :status, :integer
    end

    remove_concurrent_index_by_name :bulk_import_trackers, UNIQUE_INDEX
  end
end
