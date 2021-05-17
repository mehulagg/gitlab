# frozen_string_literal: true

class SetTraversalIdsForTopGroupsByDbUsageOnCom < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  GROUPS = [
    1,
    2,
    3
  ]
  def up
    GROUPS.each do |group_id|
      with_lock_retries do
        execute(sync_traversal_ids_sql(group_id))
      end
    end
  end

  def down
    # no-op
  end

  private

  def sync_traversal_ids_sql(group_id)
    <<~SQL
        UPDATE
          namespaces
        SET
          traversal_ids = cte.traversal_ids
        FROM
          (
            WITH RECURSIVE cte(id, traversal_ids, cycle) AS (
              VALUES
                (#{group_id}, ARRAY[#{group_id}], false)
              UNION ALL
              SELECT
                n.id,
                cte.traversal_ids || n.id,
                n.id = ANY(cte.traversal_ids)
              FROM
                namespaces n,
                cte
              WHERE
                n.parent_id = cte.id
                AND NOT cycle
            )
            SELECT
              id,
              traversal_ids
            FROM
              cte FOR
            UPDATE
              ) as cte
        WHERE
          namespaces.id = cte.id
          AND namespaces.traversal_ids <> cte.traversal_ids
    SQL
  end
end
