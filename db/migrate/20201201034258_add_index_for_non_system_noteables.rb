# frozen_string_literal: true

class AddIndexForNonSystemNoteables < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = "index_notes_on_noteable_id_and_noteable_type_minus_system"

  def up
    add_concurrent_index :notes, [:noteable_id, :noteable_type], where: "NOT system", name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :notes, INDEX_NAME
  end
end
