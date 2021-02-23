# frozen_string_literal: true

class AddRemovedAtToOncallParticipantIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false
  INDEX_NAME = 'index_incident_management_oncall_participants_is_removed'

  def up
    add_concurrent_index :incident_management_oncall_participants, :is_removed, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name(:incident_management_oncall_participants, INDEX_NAME)
  end
end
