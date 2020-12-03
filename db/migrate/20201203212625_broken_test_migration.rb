# frozen_string_literal: true

class BrokenTestMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :projects, :id, name: 'broken_test_migration_index'
  end

  def down
  end
end
