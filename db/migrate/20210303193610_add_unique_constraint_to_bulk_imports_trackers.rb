# frozen_string_literal: true

class AddUniqueConstraintToBulkImportsTrackers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false
  UNIQUE_INDEX = 'bulk_import_trackers_on_entity_id_relation_stage_unique'

  disable_ddl_transaction!

  def up
    add_concurrent_index :bulk_import_trackers,
      [:bulk_import_entity_id, :relation, :stage],
      name: UNIQUE_INDEX,
      unique: true
  end

  def down
    remove_concurrent_index_by_name :bulk_import_trackers, UNIQUE_INDEX
  end
end
