# frozen_string_literal: true

class RemoveNotNullConstraintToUserOnGroupImportStates < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_not_null_constraint :group_import_states, :user_id
  end

  def down
    add_not_null_constraint :group_import_states, :user_id, validate: false
  end
end
