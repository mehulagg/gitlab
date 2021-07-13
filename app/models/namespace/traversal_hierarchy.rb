# frozen_string_literal: true
#
# A Namespace::TraversalHierarchy is the collection of namespaces that descend
# from a root Namespace as defined by the Namespace#traversal_ids attributes.
#
# This class provides operations to be performed on the hierarchy itself,
# rather than individual namespaces.
#
# This includes methods for synchronizing traversal_ids attributes to a correct
# state. We use recursive methods to determine the correct state so we don't
# have to depend on the integrity of the traversal_ids attribute values
# themselves.
#
class Namespace
  class TraversalHierarchy
    attr_accessor :root

    UnboundedSearch = Class.new(StandardError)

    def self.for_namespace(namespace)
      new(recursive_root_ancestor(namespace))
    end

    def self.subtrees(*ranges, top_only: [], bottom_only: [])
      top_only_range = top_only.map { |top| [top, nil] }
      ranges.concat(top_only_range)

      bottom_only_range = bottom_only.map { |bottom| [nil, bottom] }
      ranges.concat(bottom_only_range)

      subtrees = ranges.map do |top, bottom|
        subtree(top: top, bottom: bottom)
      end

      if subtrees.one?
        subtrees.first
      else
        Namespace.from_union(subtrees, remove_duplicates: false, remove_order: true)
      end
    end

    def self.subtree(top: nil, bottom: nil)
      raise UnboundedSearch, 'Must bound search by either top or bottom' if top.blank? && bottom.blank?

      # Make sure we drop the STI `type = 'Group'` condition for better performance.
      # Logically equivalent so long as hierarchies remain homogeneous.
      skope = Namespace.unscope(where: :type)

      skope = case top
              when ActiveRecord::Base
                skope.where("traversal_ids @> (?)", "{#{top.id}}")
              when Array
                skope.where("traversal_ids @> (?)", "{#{top.join(',')}}")
              when ActiveRecord::Relation
                sql = top.select('traversal_ids').to_sql
                join_sql = "inner join (#{sql}) ns on namespaces.traversal_ids @> ns.traversal_ids"
                skope.joins(join_sql)
              else
                skope
              end

      if bottom
        value = case bottom
                when ActiveRecord::Base
                  bottom.traversal_ids[0..-1]
                when Array
                  bottom
                when ActiveRecord::Relation
                  bottom.select('unnest(traversal_ids)')
                end

        skope = skope.where(id: value)
      end

      skope
    end

    def initialize(root)
      raise StandardError, 'Must specify a root node' if root.parent_id

      @root = root
    end

    # Update all traversal_ids in the current namespace hierarchy.
    def sync_traversal_ids!
      # An issue in Rails since 2013 prevents this kind of join based update in
      # ActiveRecord. https://github.com/rails/rails/issues/13496
      # Ideally it would be:
      #   `incorrect_traversal_ids.update_all('traversal_ids = cte.traversal_ids')`
      sql = """
            UPDATE namespaces
            SET traversal_ids = cte.traversal_ids
            FROM (#{recursive_traversal_ids}) as cte
            WHERE namespaces.id = cte.id
              AND namespaces.traversal_ids <> cte.traversal_ids
            """
      Namespace.transaction do
        @root.lock!
        Namespace.connection.exec_query(sql)
      end
    rescue ActiveRecord::Deadlocked
      db_deadlock_counter.increment(source: 'Namespace#sync_traversal_ids!')
      raise
    end

    # Identify all incorrect traversal_ids in the current namespace hierarchy.
    def incorrect_traversal_ids
      Namespace
        .joins("INNER JOIN (#{recursive_traversal_ids}) as cte ON namespaces.id = cte.id")
        .where('namespaces.traversal_ids <> cte.traversal_ids')
    end

    private

    # Determine traversal_ids for the namespace hierarchy using recursive methods.
    # Generate a collection of [id, traversal_ids] rows.
    #
    # Note that the traversal_ids represent a calculated traversal path for the
    # namespace and not the value stored within the traversal_ids attribute.
    def recursive_traversal_ids
      root_id = Integer(@root.id)

      <<~SQL
      WITH RECURSIVE cte(id, traversal_ids, cycle) AS (
        VALUES(#{root_id}, ARRAY[#{root_id}], false)
      UNION ALL
        SELECT n.id, cte.traversal_ids || n.id, n.id = ANY(cte.traversal_ids)
        FROM namespaces n, cte
        WHERE n.parent_id = cte.id AND NOT cycle
      )
      SELECT id, traversal_ids FROM cte
      SQL
    end

    # This is essentially Namespace#root_ancestor which will soon be rewritten
    # to use traversal_ids. We replicate here as a reliable way to find the
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
