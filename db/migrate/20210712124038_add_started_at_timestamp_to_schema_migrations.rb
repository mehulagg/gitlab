# frozen_string_literal: true

class AddStartedAtTimestampToSchemaMigrations < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    add_column :schema_migrations, :started_at, :timestamptz
  end

  def down
    remove_column :schema_migrations, :started_at
  end
end
