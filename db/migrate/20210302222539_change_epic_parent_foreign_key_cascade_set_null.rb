# frozen_string_literal: true

class ChangeEpicParentForeignKeyCascadeSetNull < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_foreign_key :epics, column: :parent_id
      add_foreign_key :epics, :epics, column: :parent_id, on_delete: :nullify
    end
  end

  def down
    with_lock_retries do
      remove_foreign_key :epics, column: :parent_id
      add_foreign_key :epics, :epics, column: :parent_id, on_delete: :cascade
    end
  end
end
