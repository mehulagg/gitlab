# frozen_string_literal: true

class CreateSharedSchema < ActiveRecord::Migration[6.1]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false

  TABLES = [
    "schema_migrations",
    "background_migration_jobs",
    "batched_background_migration_jobs",
    "batched_background_migrations"
  ]

  def up
    create_schema('gitlab_shared')

    create_comment(:schema, :gitlab_shared, <<~EOS.strip)
      Schema to hold all tables shared across all databases
    EOS

    TABLES.each do |table|
      execute "ALTER TABLE #{table} SET SCHEMA gitlab_shared"
    end
  end

  def down
    drop_schema('gitlab_shared')

    TABLES.each do |table|
      execute "ALTER TABLE #{table} SET SCHEMA public"
    end
  end
end
