# frozen_string_literal: true

class FixMergeRequestAssigneeIdType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  include Gitlab::Database::DynamicModelHelpers

  DOWNTIME = false

  TABLE = 'merge_request_assignees'
  ORIGINAL_COLUMN = 'id'
  TEMPORARY_COLUMN = 'id_for_type_change'

  BATCH_SIZE = 10_000
  BATCH_INTERVAL = 5.minutes.freeze
  MIGRATION_CLASS = 'CopyColumn'

  disable_ddl_transaction!

  def up
    unless column_exists?(table, temporary_column)
      add_column(table, temporary_column, :bigint, null: false, default: 0)
    end

    install_rename_triggers(table, original_column, temporary_column)

    define_batchable_model(table).each_batch(of: BATCH_SIZE, column: original_column) do |batch, index|
      start_id, end_id = batch.pluck('MIN(id), MAX(id)').first

      migrate_in(
        index * BATCH_INTERVAL,
        MIGRATION_CLASS,
        [table, original_column, temporary_column, start_id, end_id]
      )
    end
  end

  def down
    transaction do
      trigger_name = rename_trigger_name(table, original_column, temporary_column)

      remove_rename_triggers_for_postgresql(table, trigger_name)
      remove_column(table, temporary_column)
    end
  end

  private

  def table
    TABLE
  end

  def original_column
    ORIGINAL_COLUMN
  end

  def temporary_column
    TEMPORARY_COLUMN
  end
end
