# frozen_string_literal: true

class FinalizePkPushEventPayloadsEnsureMigrationCompleted < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    ensure_batched_background_migration_is_finished(
      job_class_name: 'CopyColumnUsingBackgroundMigrationJob',
      table_name: 'push_event_payloads',
      column_name: 'event_id',
      job_arguments: [["event_id"], ["event_id_convert_to_bigint"]]
    )
  end

  def down
    # no-op, nothing to do
  end
end
