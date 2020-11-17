# frozen_string_literal: true

class AddIterationIdIndexToBoardsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_boards_on_iteration_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :boards, :iteration_id, name: INDEX_NAME
    add_concurrent_foreign_key :boards, :sprints, column: :iteration_id
  end

  def down
    with_lock_retries do
      remove_foreign_key :boards, column: :iteration_id
    end

    remove_concurrent_index :boards, :iteration_id
  end
end
