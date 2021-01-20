# frozen_string_literal: true

class ExtendIndexOnCiBuildsMetadata < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  OLD_INDEX = :index_ci_builds_metadata_on_build_id_and_interruptible
  NEW_INDEX = :index_ci_builds_metadata_on_build_id_and_interruptible_covering_id

  def up
    execute <<~SQL
      CREATE INDEX CONCURRENTLY #{NEW_INDEX}
      ON ci_builds_metadata (build_id) INCLUDE (id)
      WHERE interruptible = true
    SQL

    remove_concurrent_index_by_name :ci_builds_metadata, OLD_INDEX
  end

  def down
    add_concurrent_index :ci_builds_metadata, :build_id, where: 'interruptible = true', name: OLD_INDEX

    remove_concurrent_index_by_name :ci_builds_metadata, NEW_INDEX
  end
end
