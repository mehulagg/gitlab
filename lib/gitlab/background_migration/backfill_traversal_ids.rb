# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillTraversalIds
      def perform(min_namespace_id, max_namespace_id)
        batch = Namespace.where(id: min_namespace_id..max_namespace_id)
                         .where('parent_id IS NOT NULL')
                         .where(traversal_ids: nil)

        update_sql = <<~SQL
          UPDATE namespaces
          SET traversal_ids = calculated_ids.traversal_ids
          FROM #{calculated_traversal_ids(batch)} calculated_ids
          WHERE namespaces.id = calculated_ids.id
        SQL

        ActiveRecord::Base.connection.execute(update_sql)
      end

      private

      # Calculate the ancestor path for a given set of namespaces.
      def calculated_traversal_ids(batch)
        <<~SQL
          (
            WITH RECURSIVE cte(source_id, namespace_id, parent_id, height) AS (
              (
                SELECT batch.id, batch.id, batch.parent_id, 1
                FROM (#{batch.to_sql}) AS batch
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
      end
    end
  end
end
