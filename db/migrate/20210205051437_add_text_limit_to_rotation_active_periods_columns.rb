# frozen_string_literal: true

class AddTextLimitToRotationActivePeriodsColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :incident_management_oncall_rotations, :active_period_start, 5
    add_text_limit :incident_management_oncall_rotations, :active_period_end, 5
  end

  def down
    remove_text_limit :incident_management_oncall_rotations, :active_period_start
    remove_text_limit :incident_management_oncall_rotations, :active_period_end
  end
end
