# frozen_string_literal: true

class FinalizePkPushEventPayloadsSwapColumns < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  TABLE_NAME = 'push_event_payloads'
  INDEX_NAME = 'index_push_event_payloads_on_event_id_convert_to_bigint'

  def up
    with_lock_retries do
      # Swap columns
      rename_column TABLE_NAME, :event_id, :event_id_convert_to_bigint_tmp
      rename_column TABLE_NAME, :event_id_convert_to_bigint, :event_id
      rename_column TABLE_NAME, :event_id_convert_to_bigint_tmp, :event_id_convert_to_bigint

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

  def down
    # ???
  end
end
