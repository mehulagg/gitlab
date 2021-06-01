# frozen_string_literal: true

class CopyPendingBuildsToPendingBuildsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  class Build < ActiveRecord::Base
    include EachBatch

    self.table_name = 'ci_builds'
    self.inheritance_column = :_type_disabled
  end

  def up
    # testing only
    execute 'TRUNCATE ci_pending_builds'

    # For testing, we're operating on an older state - so we need to go back one more day
    start_id = Build.where(status: 'pending', type: 'Ci::Build').where('updated_at > ?', 2.days.ago).pluck('MIN(id)')

    Build.where('id > ?', start_id).each_batch(of: 1000) do |batch|
      min_id, max_id = batch.pluck('MIN(id)', 'MAX(id)').first

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
  end

  def down
    # no-op
  end
end
