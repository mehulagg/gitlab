# frozen_string_literal: true
#
# A Namespace::TraversalHierarchy is the collection of namespaces that descend
# from a root Namespace as defined by the Namespace#traversal_ids8 attributes.
#
# This class provides operations to be performed on the hierarchy itself,
# rather than individual namespaces.
#
# This includes methods for synchronizing traversal_ids8 attributes to a correct
# state. We use recursive methods to determine the correct state so we don't
# have to depend on the integrity of the traversal_ids8 attribute values
# themselves.
#
class Namespace
  class TraversalHierarchy
    attr_accessor :root

    def self.for_namespace(namespace)
      new(recursive_root_ancestor(namespace))
    end

    def initialize(root)
      raise StandardError, 'Must specify a root node' if root.parent_id

      @root = root
    end

    # Update all traversal_ids8 in the current namespace hierarchy.
    def sync_traversal_ids!
      # An issue in Rails since 2013 prevents this kind of join based update in
      # ActiveRecord. https://github.com/rails/rails/issues/13496
      # Ideally it would be:
      #   `incorrect_traversal_ids.update_all('traversal_ids8 = cte.traversal_ids8')`
      sql = """
            UPDATE namespaces
            SET traversal_ids8 = cte.traversal_ids8
            FROM (#{recursive_traversal_ids}) as cte
            WHERE namespaces.id = cte.id
              AND namespaces.traversal_ids8 <> cte.traversal_ids8
            """
      Namespace.transaction do
        @root.lock!
        Namespace.connection.exec_query(sql)
      end
    rescue ActiveRecord::Deadlocked
      db_deadlock_counter.increment(source: 'Namespace#sync_traversal_ids!')
      raise
    end

    # Identify all incorrect traversal_ids8 in the current namespace hierarchy.
    def incorrect_traversal_ids
      Namespace
        .joins("INNER JOIN (#{recursive_traversal_ids}) as cte ON namespaces.id = cte.id")
        .where('namespaces.traversal_ids8 <> cte.traversal_ids8')
    end

    private

    # Determine traversal_ids8 for the namespace hierarchy using recursive methods.
    # Generate a collection of [id, traversal_ids8] rows.
    #
    # Note that the traversal_ids8 represent a calculated traversal path for the
    # namespace and not the value stored within the traversal_ids8 attribute.
    def recursive_traversal_ids
      root_id = Integer(@root.id)

      <<~SQL
      WITH RECURSIVE cte(id, traversal_ids8, cycle) AS (
        VALUES(#{root_id}, ARRAY[#{root_id}]::bigint[], false)
      UNION ALL
        SELECT n.id, cte.traversal_ids8 || n.id::bigint, n.id = ANY(cte.traversal_ids8)
        FROM namespaces n, cte
        WHERE n.parent_id = cte.id AND NOT cycle
      )
      SELECT id, traversal_ids8 FROM cte
      SQL
    end

    # This is essentially Namespace#root_ancestor which will soon be rewritten
    # to use traversal_ids8. We replicate here as a reliable way to find the
    # root using recursive methods.
    def self.recursive_root_ancestor(namespace)
      Gitlab::ObjectHierarchy
        .new(Namespace.where(id: namespace))
        .base_and_ancestors
        .reorder(nil)
        .find_by(parent_id: nil)
    end

    def db_deadlock_counter
      Gitlab::Metrics.counter(:db_deadlock, 'Counts the times we have deadlocked in the database')
    end
  end
end
