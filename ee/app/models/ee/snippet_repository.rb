# frozen_string_literal: true

module EE
  module SnippetRepository
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel

      with_replicator Geo::SnippetRepositoryReplicator
    end

    class_methods do
      # @param primary_key_in [Range, SnippetRepository] arg to pass to primary_key_in scope
      # @param node [GeoNode] defaults to ::Gitlab::Geo.current_node
      # @return [ActiveRecord::Relation<SnippetRepository>] everything that should be synced to this node, restricted by primary key
      def replicables_for_geo_node(primary_key_in, node = ::Gitlab::Geo.current_node)
        # Not implemented yet. Should be responsible for selective sync
        all
      end
    end

    # Geo checks this method in FrameworkRepositorySyncService to avoid
    # snapshotting repositories using object pools
    def pool_repository
      nil
    end
  end
end
