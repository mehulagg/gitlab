# frozen_string_literal: true

module Namespaces
  module Traversal
    module LinearScopes
      extend ActiveSupport::Concern

      class_methods do
        # When filtering namespaces by the traversal_ids column to compile a
        # list of namespace IDs, it's much faster to reference the ID in
        # traversal_ids than the primary key ID column.
        def as_ids
          return super unless use_traversal_ids?

          select('namespaces.traversal_ids[array_length(namespaces.traversal_ids, 1)] AS id')
        end

        def self_and_descendants
          return super unless use_traversal_ids?

          sql = without_sti_condition.select('traversal_ids').to_sql
          join_sql = "inner join (#{sql}) ns on namespaces.traversal_ids @> ns.traversal_ids"
          unscoped.joins(join_sql)
        end

        def self_and_descendant_ids
          self_and_descendants.as_ids
        end

        # Make sure we drop the STI `type = 'Group'` condition for better performance.
        # Logically equivalent so long as hierarchies remain homogeneous.
        def without_sti_condition
          unscope(where: :type)
        end

        private

        def use_traversal_ids?
          Feature.enabled?(:use_traversal_ids, default_enabled: :yaml)
        end

      end
    end
  end
end
