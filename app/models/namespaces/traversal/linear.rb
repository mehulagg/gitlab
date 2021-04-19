# frozen_string_literal: true
#
# Query a recursively defined namespace hierarchy using linear methods through
# the traversal_ids attribute.
#
# Namespace is a nested hierarchy of one parent to many children. A search
# using only the parent-child relationships is a slow operation. This process
# was previously optimized using Postgresql recursive common table expressions
# (CTE) with acceptable performance. However, it lead to slower than possible
# performance, and resulted in complicated queries that were difficult to make
# performant.
#
# Instead of searching the hierarchy recursively, we store a `traversal_ids`
# attribute on each node. The `traversal_ids` is an ordered array of Namespace
# IDs that define the traversal path from the root Namespace to the current
# Namespace.
#
# For example, suppose we have the following Namespaces:
#
# GitLab (id: 1) > Engineering (id: 2) > Manage (id: 3) > Access (id: 4)
#
# Then `traversal_ids` for group "Access" is [1, 2, 3, 4]
#
# And we can match against other Namespace `traversal_ids` such that:
#
# - Ancestors are [1], [1, 2], [1, 2, 3]
# - Descendants are [1, 2, 3, 4, *]
# - Root is [1]
# - Hierarchy is [1, *]
#
# Note that this search method works so long as the IDs are unique and the
# traversal path is ordered from root to leaf nodes.
#
# We implement this in the database using Postgresql arrays, indexed by a
# generalized inverted index (gin).
module Namespaces
  module Traversal
    module Linear
      extend ActiveSupport::Concern

      UnboundedSearch = Class.new(StandardError)

      included do
        after_create :sync_traversal_ids, if: -> { sync_traversal_ids? }
        after_update :sync_traversal_ids, if: -> { sync_traversal_ids? && saved_change_to_parent_id? }

        scope :traversal_ids_contains, ->(ids) { where("traversal_ids @> (?)", ids) }
        scope :traversal_ids_contained_by, ->(ids) { where("traversal_ids <@ (?)", ids) }
      end

      def sync_traversal_ids?
        Feature.enabled?(:sync_traversal_ids, root_ancestor, default_enabled: :yaml)
      end

      def use_traversal_ids?
        return false unless Feature.enabled?(:use_traversal_ids, root_ancestor, default_enabled: :yaml)

        !traversal_ids.blank?
      end

      def self_and_descendants
        return super unless use_traversal_ids?

        lineage(top: self)
      end

      def ancestors(hierarchy_order: nil)
        return super() unless use_traversal_ids?

        lineage(bottom: latest_parent_id, hierarchy_order: hierarchy_order)
      end

      def descendants
        return super unless use_traversal_ids?

        self_and_descendants.where.not(id: id)
      end

      private

      # Update the traversal_ids for the full hierarchy.
      #
      # NOTE: self.traversal_ids will be stale. Reload for a fresh record.
      def sync_traversal_ids
        # Clear any previously memoized root_ancestor as our ancestors have changed.
        clear_memoization(:root_ancestor)

        Namespace::TraversalHierarchy.for_namespace(root_ancestor).sync_traversal_ids!
      end

      # Make sure we drop the STI `type = 'Group'` condition for better performance.
      # Logically equivalent so long as hierarchies remain homogeneous.
      def without_sti_condition
        self.class.unscope(where: :type)
      end

      # Search this namespace's lineage. Bound inclusively by top node.
      def lineage(top: nil, bottom: nil, hierarchy_order: nil)
        raise UnboundedSearch.new('Must bound search by a top') unless top || bottom

        skope = without_sti_condition

        if top
          skope = skope.traversal_ids_contains(latest_traversal_ids(top))
        end

        if bottom
          skope = skope.traversal_ids_contained_by(latest_traversal_ids(bottom))
        end

        # The original `with_depth` attribute in ObjectHierarchy increments as you
        # walk away from the "base" namespace. This direction changes depending on
        # if you are walking up the ancestors or down the descendants.
        if hierarchy_order
          depth_sql = "ABS(array_length((#{latest_traversal_ids.to_sql}), 1) - array_length(traversal_ids, 1))"
          skope = skope.select(skope.arel_table[Arel.star], "#{depth_sql} as depth")
                       .order(depth: hierarchy_order)
        end

        skope
      end

      # traversal_ids are a cached value.
      #
      # The traversal_ids value in a loaded object can become stale when compared
      # to the database value. For example, if you load a hierarchy and then move
      # a group, any previously loaded descendant objects will have out of date
      # traversal_ids.
      #
      # To solve this problem, we never depend on the object's traversal_ids
      # value. We always query the database first with a sub-select for the
      # latest traversal_ids.
      #
      # Note that ActiveRecord will cache query results. You can avoid this by
      # using `Model.uncached { ... }`
      def latest_traversal_ids(namespace = self)
        without_sti_condition.where('id = (?)', namespace)
                .select('traversal_ids as latest_traversal_ids')
      end

      def latest_parent_id(namespace = self)
        without_sti_condition.where(id: namespace).select(:parent_id)
      end
    end
  end
end
