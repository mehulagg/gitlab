# frozen_string_literal: true

class FinalizeEventsBigintConversion < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers


  disable_ddl_transaction!

  TABLE_NAME = 'events'

  # Indexes to copy
  # "events_pkey" PRIMARY KEY, btree (id)
  # "index_events_on_project_id_and_id" btree (project_id, id)
  # "index_events_on_project_id_and_id_desc_on_merged_action" btree (project_id, id DESC) WHERE action = 7

  # FKs to copy
  # TABLE "push_event_payloads" CONSTRAINT "fk_36c74129da" FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE

  def up
    ensure_batched_background_migration_is_finished(
      job_class_name: 'CopyColumnUsingBackgroundMigrationJob',
      table_name: 'events',
      column_name: 'id',
      job_arguments: [["id"], ["id_convert_to_bigint"]]
    )

    swap
  end

  def down
    swap
  end

  private

  def swap
    # Copy indexes
    #   "events_pkey" PRIMARY KEY, btree (id)
    add_concurrent_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: 'index_events_on_id_convert_to_bigint'
    #   "index_events_on_project_id_and_id" btree (project_id, id)
    add_concurrent_index TABLE_NAME, [:project_id, :id_convert_to_bigint], name: 'index_events_on_project_id_and_id__convert_to_bigint'
    #   "index_events_on_project_id_and_id_desc_on_merged_action" btree (project_id, id DESC) WHERE action = 7
    add_concurrent_index TABLE_NAME, [:project_id, :id_convert_to_bigint], order: { id_convert_to_bigint: :desc },
      where: "action = 7", name: 'index_events_on_project_id_and_id_convert_to_bigint_desc_on_merged_action'

    # Copy FKs
    #   TABLE "push_event_payloads" CONSTRAINT "fk_36c74129da" FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
    fk_event_id = concurrent_foreign_key_name('push_event_payloads', :event_id)
    fk_event_id_tmp = "#{fk_event_id}_tmp"
    execute <<~SQL
      ALTER TABLE push_event_payloads
      ADD CONSTRAINT #{fk_event_id_tmp}
      FOREIGN KEY (event_id)
      REFERENCES #{TABLE_NAME} (id_convert_to_bigint)
      ON DELETE CASCADE
      NOT VALID;
    SQL
    disable_statement_timeout do
      execute("ALTER TABLE push_event_payloads VALIDATE CONSTRAINT #{fk_event_id_tmp}")
    end

    with_lock_retries(safe: true) do
      swap_column_names TABLE_NAME, :id, :id_convert_to_bigint # rubocop:disable Migration/WithLockRetriesDisallowedMethod

      # Swap defaults
      change_column_default TABLE_NAME, :event_id, nil
      change_column_default TABLE_NAME, :event_id_convert_to_bigint, 0

      # Swap PK constraint
      execute "ALTER TABLE #{TABLE_NAME} DROP CONSTRAINT push_event_payloads_pkey"
      rename_index TABLE_NAME, index_name(TABLE_NAME, column: :event_id), 'push_event_payloads_pkey'
      execute "ALTER TABLE #{TABLE_NAME} ADD CONSTRAINT push_event_payloads_pkey PRIMARY KEY USING INDEX push_event_payloads_pkey"

      # Drop FK fk_36c74129da
      remove_foreign_key TABLE_NAME, name: concurrent_foreign_key_name(TABLE_NAME, :event_id)
      # Change the name of the FK for event_id_convert_to_bigint to the FK name for event_id
      execute <<~SQL
          ALTER TABLE #{TABLE_NAME}
          RENAME CONSTRAINT #{concurrent_foreign_key_name(TABLE_NAME, :event_id_convert_to_bigint)}
          TO #{concurrent_foreign_key_name(TABLE_NAME, :event_id)}
      SQL
    end
  end
end
