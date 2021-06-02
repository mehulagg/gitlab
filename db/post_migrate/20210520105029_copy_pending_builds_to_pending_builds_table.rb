# frozen_string_literal: true

class CopyPendingBuildsToPendingBuildsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  BATCH_SIZE = 10000
  TEMP_INDEX = 'ci_builds_pending_builds_id'

  disable_ddl_transaction!

  class Build < ActiveRecord::Base
    include EachBatch

    self.table_name = 'ci_builds'
    self.inheritance_column = :_type_disabled

    scope :pending, -> do
      where(status: 'pending')
        .where(type: 'Ci::Build')
        .where('updated_at > ?', 24.hours.ago)
        .order('id ASC')
    end
  end

  def up
    # testing only
    execute 'truncate ci_pending_builds'

    add_concurrent_index :ci_builds, :id, where: "status = 'pending' AND type = 'Ci::Build'", name: TEMP_INDEX

    Build.pending.limit(1).pluck(:id).first.try do |id|
      Build.where('id >= ?', id).each_batch(of: BATCH_SIZE) do |batch|
        min_id, max_id = batch.pluck('MIN(id), MAX(id)').first

        execute <<~SQL
          WITH pending_builds AS MATERIALIZED (
            SELECT id,
                   project_id
            FROM ci_builds
            WHERE status = 'pending' AND type = 'Ci::Build'
            AND id BETWEEN #{min_id} AND #{max_id}
          )
          INSERT INTO ci_pending_builds (build_id, project_id)
            SELECT id,
                   project_id
            FROM pending_builds
            ON CONFLICT DO NOTHING
        SQL
      end
    end
  ensure
    # commented out for testing
    # remove_concurrent_index_by_name :ci_builds, name: TEMP_INDEX
  end

  def down
    remove_concurrent_index_by_name :ci_builds, name: TEMP_INDEX
  end
end
