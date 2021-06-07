# frozen_string_literal: true

class SpecifyTableOwnership < ActiveRecord::Migration[6.1]
  include Gitlab::Database::Meta::MigrationHelper

  def up
    table_description(:ci_builds, owner: 'group::verify')
    table_description(:schema_migrations, owner: 'group::database')
  end

  def down
    clear_table_description(:ci_builds)
    clear_table_description(:schema_migrations)
  end
end
