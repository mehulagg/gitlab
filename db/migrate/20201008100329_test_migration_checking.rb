# frozen_string_literal: true

class TestMigrationChecking < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :users, :email, name: 'foobartest'
  end

  def down
    remove_concurrent_index_by_name :projects, :index_projects_on_name_and_id
  end
end
