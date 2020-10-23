# frozen_string_literal: true

module Geo::SelectiveSync
  extend ActiveSupport::Concern

  def selective_sync?
    selective_sync_type.present?
  end

  def selective_sync_by_namespaces?
    selective_sync_type == 'namespaces'
  end

  def selective_sync_by_shards?
    selective_sync_type == 'shards'
  end

  # This method should only be used when:
  #
  # - Selective sync is enabled
  # - A replicable model is associated to Namespace but not to any Project
  #
  # When selectively syncing by namespace: We must sync every replicable of
  # every selected namespace and descendent namespaces.
  #
  # When selectively syncing by shard: We must sync every replicable of every
  # namespace of every project in those shards. We must also sync every ancestor
  # of those namespaces.
  #
  # When selective sync is disabled: This method raises, instead of returning
  # the technically correct `Namespace.all`, because it is easy for it to become
  # part of an unnecessarily complex and inefficient query.
  #
  # @return [ActiveRecord::Relation<Namespace>] returns namespaces based on selective sync settings
  def namespaces_for_group_owned_replicables
    if selective_sync_by_namespaces?
      selected_namespaces_and_descendants
    elsif selective_sync_by_shards?
      selected_leaf_namespaces_and_ancestors
    else
      raise 'This scope should not be needed without selective sync'
    end
  end

  private

  def selected_namespaces_and_descendants
    relation = selected_namespaces_and_descendants_cte.apply_to(Namespace.all)
    read_only_relation(relation)
  end

  def selected_namespaces_and_descendants_cte
    namespaces_table = Namespace.arel_table

    cte = Gitlab::SQL::RecursiveCTE.new(:base_and_descendants)

    cte << geo_node_namespace_links
      .select(geo_node_namespace_links.arel_table[:namespace_id].as('id'))
      .except(:order)

    # Recursively get all the descendants of the base set.
    cte << Namespace
      .select(namespaces_table[:id])
      .from([namespaces_table, cte.table])
      .where(namespaces_table[:parent_id].eq(cte.table[:id]))
      .except(:order)

    cte
  end

  def selected_leaf_namespaces_and_ancestors
    relation = selected_leaf_namespaces_and_ancestors_cte.apply_to(Namespace.all)
    read_only_relation(relation)
  end

  # Returns a CTE selecting namespace IDs for selected shards
  #
  # When we need to sync resources that are only associated with namespaces,
  # but the instance is selectively syncing by shard, we must sync every
  # namespace of every project in those shards. We must also sync every
  # ancestor of those namespaces.
  def selected_leaf_namespaces_and_ancestors_cte
    namespaces_table = Namespace.arel_table

    cte = Gitlab::SQL::RecursiveCTE.new(:base_and_ancestors)

    cte << Namespace
      .select(namespaces_table[:id], namespaces_table[:parent_id])
      .where(id: projects.select(:namespace_id))

    # Recursively get all the ancestors of the base set.
    cte << Namespace
      .select(namespaces_table[:id], namespaces_table[:parent_id])
      .from([namespaces_table, cte.table])
      .where(namespaces_table[:id].eq(cte.table[:parent_id]))
      .except(:order)

    cte
  end

  def read_only_relation(relation)
    # relations using a CTE are not safe to use with update_all as it will
    # throw away the CTE, hence we mark them as read-only.
    relation.extend(Gitlab::Database::ReadOnlyRelation)
    relation
  end
end
