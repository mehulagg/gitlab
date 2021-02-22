# frozen_string_literal: true

class AddRemovedAtToOncallParticipantIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_concurrent_index :incident_management_oncall_participants, :removed_at
  end

  def down
    remove_concurrent_index :incident_management_oncall_participants, :removed_at
  end
end
