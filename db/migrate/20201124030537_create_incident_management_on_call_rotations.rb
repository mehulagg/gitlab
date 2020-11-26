# frozen_string_literal: true

class CreateIncidentManagementOnCallRotations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      unless table_exists?(:incident_management_oncall_rotations)
        create_table :incident_management_oncall_rotations do |t|
          t.timestamps_with_timezone
          t.references :oncall_schedule, index: false, null: false, foreign_key: { to_table: :incident_management_oncall_schedules, on_delete: :cascade }
          t.text :name, null: false
          t.integer :rotation_length
          t.integer :rotation_length_unit
          t.datetime_with_timezone :starts_at
          t.text :timezone

          t.index %w(oncall_schedule_id id), name: 'index_im_oncall_schedules_on_schedule_id_and_id', unique: true, using: :btree
        end
      end
    end

    add_text_limit :incident_management_oncall_rotations, :name, 200
  end

  def down
    with_lock_retries do
      drop_table :incident_management_oncall_rotations
    end
  end
end
