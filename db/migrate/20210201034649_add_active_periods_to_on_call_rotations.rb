# frozen_string_literal: true

class AddActivePeriodsToOnCallRotations < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20210205051437_add_text_limit_to_rotation_active_periods_columns
  def change
    add_column :incident_management_oncall_rotations, :active_period_start, :time, null: true
    add_column :incident_management_oncall_rotations, :active_period_end, :time, null: true
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
