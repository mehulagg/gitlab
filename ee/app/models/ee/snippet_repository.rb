# frozen_string_literal: true

module EE
  module SnippetRepository
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      with_replicator Geo::SnippetRepositoryReplicator
    end

    class_methods do
      # @param [Integer, String, Range, Array] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation<SnippetRepository>] everything that should be synced to this node, restricted by primary key
      def replicables_for_geo_node(primary_key_in, node = ::Gitlab::Geo.current_node)
        # Not implemented yet. Should be responible for selective sync
        none
      end
    end
  end
end
