# frozen_string_literal: true

class BackfillTraversalIdsCom < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  DELAY = 2 # seconds

  def up
    return unless Gitlab.com?

    # All user namespaces.
    Namespace.where(type: nil).in_batches do |relation|
      relation.update_all('traversal_ids = [id]')
      sleep DELAY
    end

    # Top level groups.
    Group.where(parent_id: nil).in_batches do |relation|
      relation.update_all('traversal_ids = [id]')
      sleep DELAY
    end

    # Sub-groups.

    # Calculate the ancestor path for a given set of namespaces.
    calculated_ids = <<~SQL
    (
      WITH RECURSIVE cte(source_id, namespace_id, parent_id, height) AS (
        (
          SELECT batch.id, batch.id, batch.parent_id, 1
          FROM (%{batch}) AS batch
        )
        UNION ALL
        (
          SELECT cte.source_id, n.id, n.parent_id, cte.height+1
          FROM namespaces n, cte
          WHERE n.id = cte.parent_id
        )
      )
      SELECT flat_hierarchy.source_id as id,
             array_agg(flat_hierarchy.namespace_id ORDER BY flat_hierarchy.height DESC) as traversal_ids
      FROM (SELECT * FROM cte FOR UPDATE) flat_hierarchy
      GROUP BY flat_hierarchy.source_id
    )
    SQL

    Group.where.not(parent_id: nil).order(:parent_id, :id).in_batches do |batch|
      batched_calculated_ids = calculated_ids % {batch: batch.to_sql}

      update_sql = <<~SQL
        UPDATE namespaces
        SET traversal_ids = calculated_ids.traversal_ids
        FROM #{batched_calculated_ids} calculated_ids
        WHERE namespaces.id = calculated_ids.id
      SQL

      execute update_sql

      sleep DELAY
    end
  end
end
