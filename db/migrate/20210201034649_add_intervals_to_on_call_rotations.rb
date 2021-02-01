# frozen_string_literal: true

class AddIntervalsToOnCallRotations < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Migration/Datetime
    add_column :incident_management_oncall_rotations, :interval_start, :datetime, null: true
    add_column :incident_management_oncall_rotations, :interval_end, :datetime, null: true
    # rubocop:enable Migration/Datetime
  end
end
