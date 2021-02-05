# frozen_string_literal: true

class AddIntervalsToOnCallRotations < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20210205051437_add_text_limit_to_rotation_intervals_columns
  def change
    add_column :incident_management_oncall_rotations, :interval_start, :text, null: true
    add_column :incident_management_oncall_rotations, :interval_end, :text, null: true
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
