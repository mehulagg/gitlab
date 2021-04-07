# frozen_string_literal: true

class AddIndexTodosOnUserAndState < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false
  INDEX_NAME = 'index_todos_on_user_id_and_state'

  def up
    add_concurrent_index :todos, [:user_id, :state], name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :todos, INDEX_NAME
  end
end
