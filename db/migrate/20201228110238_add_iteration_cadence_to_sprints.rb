# frozen_string_literal: true

class AddIterationCadenceToSprints < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_sprints_iteration_cadence_id'

  def up
    with_lock_retries do
      add_column :sprints, :iteration_cadence_id, :integer unless column_exists?(:sprints, :iteration_cadence_id)
    end

    add_concurrent_index :sprints, :iteration_cadence_id, name: INDEX_NAME
    add_concurrent_foreign_key :sprints, :iteration_cadences, column: :iteration_cadence_id, on_delete: :cascade
  end

  def down
    remove_foreign_key_if_exists :sprints, :iteration_cadence
    remove_concurrent_index_by_name :sprints, INDEX_NAME

    with_lock_retries do
      remove_column :sprints, :iteration_cadence_id if column_exists?(:sprints, :iteration_cadence_id)
    end
  end
end
