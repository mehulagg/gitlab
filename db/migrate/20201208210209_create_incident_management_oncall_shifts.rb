# frozen_string_literal: true

class CreateIncidentManagementOncallShifts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  ROTATION_INDEX_NAME = 'index_inc_mgmnt_oncall_shifts_on_rotation_id'
  PARTICIPANT_INDEX_NAME = 'index_inc_mgmnt_oncall_shifts_on_participant_id'
  UNIQUE_INDEX_NAME = 'index_inc_mgmnt_oncall_shifts_on_rotation_id_and_starts_at'

  def up
    unless table_exists?(:incident_management_oncall_shifts)
      with_lock_retries do
        create_table :incident_management_oncall_shifts do |t|
          t.references :rotation, index: false, null: false, foreign_key: { to_table: :incident_management_oncall_rotations, on_delete: :cascade }
          t.references :participant, index: false, null: false, foreign_key: { to_table: :incident_management_oncall_participants, on_delete: :cascade }
          t.datetime_with_timezone :starts_at, null: false
          t.datetime_with_timezone :ends_at, null: false

          t.index :participant_id, name: PARTICIPANT_INDEX_NAME
          t.index [:rotation_id, :starts_at], unique: true, name: UNIQUE_INDEX_NAME
        end
      end
    end
  end

  def down
    drop_table :incident_management_oncall_shifts
  end
end
