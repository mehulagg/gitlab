# frozen_string_literal: true

class UpdateExistingSubgroupToMatchVisibilityLevelOfParent < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  class Namespace < ActiveRecord::Base
    self.table_name = 'namespaces'
  end

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    update_group_visibility_level
  end

  def down
    # no-op
  end

  def update_group_visibility_level
    group_ids = execute <<~SQL
      SELECT ARRAY_TO_STRING(ARRAY_AGG(id), ',') as ids, min as level FROM (WITH RECURSIVE base_and_descendants AS (
        (SELECT visibility_level AS strictest_parent_level,
                namespaces.*
          FROM namespaces
          WHERE namespaces.type IN ('Group'))
        UNION
        (SELECT LEAST(namespaces.visibility_level, base_and_descendants.strictest_parent_level) AS strictest_parent_level,
                namespaces.*
        FROM namespaces,
              base_and_descendants
        WHERE namespaces.type IN ('Group')
          AND namespaces.parent_id = base_and_descendants.id))
        SELECT id, MIN(strictest_parent_level) as min
        FROM base_and_descendants
        WHERE visibility_level > strictest_parent_level
        GROUP BY id) as t1
      GROUP BY level
    SQL

    group_ids = group_ids.each do |row|
      ids = row.fetch('ids', nil)
      level = row.fetch('level')
      return unless ids
      execute("UPDATE namespaces
                SET visibility_level = #{level}
                WHERE namespaces.id IN (#{ids})")
    end
  end
end
