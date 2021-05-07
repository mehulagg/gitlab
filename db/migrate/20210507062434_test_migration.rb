# frozen_string_literal: true

class TestMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_concurrent_index :users, :id, name: 'foobartest'

    execute "SELECT pg_sleep(10), 'something fancy here'"
  end

  def down
    remove_concurrent_index_by_name :users, 'foobartest'
  end
end
