# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexTodosOnUserAndState < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false
  INDEX_NAME = 'todos_on_user_id_where_status_pending_or_done'

  def up
    add_concurrent_index :todos, :user_id, name: INDEX_NAME, using: :btree, where: "((state)::text = ANY ('{done,pending}'::text[]))"
  end

  def down
    remove_concurrent_index :todos, :user_id, name: INDEX_NAME
  end
end
