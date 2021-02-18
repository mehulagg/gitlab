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

      included do
        after_create :init_traversal_ids, if: -> { sync_traversal_ids? }
        before_update :update_traversal_ids, if: -> { sync_traversal_ids? && parent_changed? }
        after_update :sync_descendant_traversal_ids, if: -> { sync_traversal_ids? && saved_change_to_parent? }
      end

      def sync_traversal_ids?
        Feature.enabled?(:sync_traversal_ids, root_ancestor, default_enabled: false)
      end

      private

      def init_traversal_ids
        parent.lock!('FOR SHARE') if parent_id
        update_column(:traversal_ids, (parent&.traversal_ids || []) + [id])
      end

      def update_traversal_ids
        parent.lock!('FOR SHARE') if parent_id
        self.traversal_ids = (parent&.traversal_ids || []) + [id]
      end

      # Update the traversal_ids for all of our descendants.
      # Our parent is locked at this point.
      def sync_descendant_traversal_ids
        Namespace::TraversalHierarchy.for_namespace(self).sync_traversal_ids!
      end
    end
  end
end
