# frozen_string_literal: true

class FinalizePkPushEventPayloadsCloneIndexPushEventPayloadsOnEventIdConvertToBigint < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TABLE_NAME = :push_event_payloads
  INDEX_NAME = :index_push_event_payloads_on_event_id_convert_to_bigint

  def up
    add_concurrent_index TABLE_NAME, :event_id_convert_to_bigint, unique: true, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name(TABLE_NAME, INDEX_NAME)
  end
end
