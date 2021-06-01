# frozen_string_literal: true

class CopyPendingBuildsToPendingBuildsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  TEMP_INDEX = 'ci_builds_pending_migration'

  disable_ddl_transaction!

  class PendingBuild < ActiveRecord::Base
    include EachBatch

    self.table_name = 'ci_builds'
    self.inheritance_column = :_type_disabled

    default_scope { where(status: 'pending', type: 'Ci::Build') }
  end

  def up
    add_concurrent_index :ci_builds, %i(id project_id), where: "status = 'pending' AND type = 'Ci::Build'", name: TEMP_INDEX

    # For testing only
    execute 'TRUNCATE ci_pending_builds'

    PendingBuild.each_batch(of: 1000) do |batch|
      min_id, max_id = batch.pluck('MIN(id)', 'MAX(id)')

      execute <<~SQL
        WITH builds AS (
          SELECT id AS build_id, project_id
          FROM ci_builds
          WHERE status = 'pending'
            AND type = 'Ci::Build'
            AND id BETWEEN #{min_id} AND #{max_id}
        )
        INSERT INTO ci_pending_builds (build_id, project_id)
          SELECT * FROM builds
          ON CONFLICT DO NOTHING
      SQL
    end

    # Commented for testing
    # remove_concurrent_index_by_name :ci_builds, name: TEMP_INDEX
  end

  def down
    remove_concurrent_index_by_name :ci_builds, name: TEMP_INDEX
  end
end
