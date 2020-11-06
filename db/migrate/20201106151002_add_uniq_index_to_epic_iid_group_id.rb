# frozen_string_literal: true

class AddUniqIndexToEpicIidGroupId < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_epics_on_group_id_and_iid'

  disable_ddl_transaction!

  def up
    add_concurrent_index :epics, [:group_id, :iid], unique: true, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :epics, name: INDEX_NAME
  end
end
