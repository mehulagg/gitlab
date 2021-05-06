# frozen_string_literal: true

class FinalizePkPushEventPayloadsCloneFk36c74129da < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TABLE_NAME = :push_event_payloads

  def up
    # Duplicate fk_36c74129da FK
    add_concurrent_foreign_key TABLE_NAME, :events, column: :event_id_convert_to_bigint, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key TABLE_NAME, column: :event_id_convert_to_bigint
    end
  end
end
