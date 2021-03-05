# frozen_string_literal: true

class AddIndexToRotationsOnEndsAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_inc_mgmnt_oncall_rotations_on_start_end_and_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :incident_management_oncall_rotations, %i[starts_at ends_at id], name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :incident_management_oncall_rotations, INDEX_NAME
  end
end
