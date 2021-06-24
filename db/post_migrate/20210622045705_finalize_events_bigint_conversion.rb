# frozen_string_literal: true

class FinalizeEventsBigintConversion < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TABLE_NAME = 'events'

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
    add_concurrent_index TABLE_NAME, [:project_id, :id_convert_to_bigint], name: 'index_events_on_project_id_and_id_convert_to_bigint'
    #   "index_events_on_project_id_and_id_desc_on_merged_action" btree (project_id, id DESC) WHERE action = 7
    add_concurrent_index TABLE_NAME, [:project_id, :id_convert_to_bigint], order: { id_convert_to_bigint: :desc },
      where: "action = 7", name: 'index_events_on_project_id_and_id_bigint_desc_on_merged_action'

    # Copy FKs
    #   TABLE "push_event_payloads" CONSTRAINT "fk_36c74129da" FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
    fk_event_id = concurrent_foreign_key_name('push_event_payloads', :event_id)
    fk_event_id_tmp = "#{fk_event_id}_tmp"
    add_concurrent_foreign_key :push_event_payloads, :events,
      column: :event_id, target_column: :id_convert_to_bigint,
      name: fk_event_id_tmp,
      on_delete: :cascade

    with_lock_retries(safe: true) do
      swap_column_names TABLE_NAME, :id, :id_convert_to_bigint # rubocop:disable Migration/WithLockRetriesDisallowedMethod

      # Swap defaults
      execute "ALTER SEQUENCE events_id_seq OWNED BY #{TABLE_NAME}.id"
      change_column_default TABLE_NAME, :id, -> { "nextval('events_id_seq'::regclass)" }
      change_column_default TABLE_NAME, :id_convert_to_bigint, 0

      # Swap PK constraint
      execute "ALTER TABLE #{TABLE_NAME} DROP CONSTRAINT events_pkey CASCADE" # this will drop fk_36c74129da
      rename_index TABLE_NAME, index_name(TABLE_NAME, column: :id), 'events_pkey'
      execute "ALTER TABLE #{TABLE_NAME} ADD CONSTRAINT events_pkey PRIMARY KEY USING INDEX events_pkey"

      # Rename the rest of the indexes
      # rename_index TABLE_NAME, 'index_events_on_project_id_and_id_convert_to_bigint', 'index_events_on_project_id_and_id'
      # rename_index TABLE_NAME, 'index_events_on_project_id_and_id_bigint_desc_on_merged_action', 'index_events_on_project_id_and_id_desc_on_merged_action'

      # Change the name of the temporary FK
      execute <<~SQL
          ALTER TABLE push_event_payloads
          RENAME CONSTRAINT #{fk_event_id_tmp}
          TO #{fk_event_id}
      SQL
    end
  end
end
