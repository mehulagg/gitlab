# frozen_string_literal: true

class AddRemovedAtToOncallParticipant < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :incident_management_oncall_participants, :is_removed, :boolean, default: false
    end
  end

  def down
    remove_column :incident_management_oncall_participants, :is_removed
  end
end
