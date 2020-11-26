# frozen_string_literal: true

class AddIncidentManagementOnCallParticipants < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  PARTICPANT_INDEX_NAME = 'index_oncall_particpants_on_oncall_rotation_id'
  UNIQUE_INDEX_NAME = 'index_oncall_particpants_on_user_id_and_rotation_id'

  def up
    with_lock_retries do
      unless table_exists?(:incident_management_oncall_participants)
        create_table :incident_management_oncall_participants do |t|
          t.references :oncall_rotation, index: false, null: false, foreign_key: { to_table: :incident_management_oncall_rotations, on_delete: :cascade }
          t.references :user, index: false, null: false, foreign_key: { on_delete: :cascade }

          t.index :oncall_rotation_id, name: PARTICPANT_INDEX_NAME
          t.index [:user_id, :oncall_rotation_id], unique: true, name: UNIQUE_INDEX_NAME
        end
      end
    end
  end

  def down
    drop_table :incident_management_oncall_participants
  end
end
