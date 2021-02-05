# frozen_string_literal: true

class AddTextLimitToRotationIntervalsColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :incident_management_oncall_rotations, :interval_start, 5
    add_text_limit :incident_management_oncall_rotations, :interval_end, 5
  end

  def down
    remove_text_limit :incident_management_oncall_rotations, :interval_start
    remove_text_limit :incident_management_oncall_rotations, :interval_end
  end
end
