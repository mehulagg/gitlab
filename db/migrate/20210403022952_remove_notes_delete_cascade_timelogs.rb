# frozen_string_literal: true

class RemoveNotesDeleteCascadeTimelogs < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_timelogs_on_note_id'

  disable_ddl_transaction!

  def up
    with_lock_retries do
      remove_foreign_key_if_exists :timelogs, :notes, column: :note_id
    end

    add_concurrent_foreign_key :timelogs, :notes, column: :note_id, on_delete: :nullify
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists :timelogs, :notes, column: :note_id
    end

    add_concurrent_foreign_key :timelogs, :notes, column: :note_id, on_delete: :cascade
  end
end
