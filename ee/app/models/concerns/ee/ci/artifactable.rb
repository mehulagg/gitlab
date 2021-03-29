# frozen_string_literal: true

module EE
  module Ci
    module Artifactable
      extend ActiveSupport::Concern

      class_methods do
        # @param primary_key_in [Range, Ci::{Pipeline|Job}Artifact] arg to pass to primary_key_in scope
        # @return [ActiveRecord::Relation<Ci::{Pipeline|Job}PipelineArtifact>] everything that should be synced to this node, restricted by primary key
        def replicables_for_current_secondary(primary_key_in)
          node = ::Gitlab::Geo.current_node

          primary_key_in(primary_key_in)
            .merge(selective_sync_scope(node))
            .merge(object_storage_scope(node))
        end

        def object_storage_scope(node)
          return all if node.sync_object_storage?

          with_files_stored_locally
        end

        def selective_sync_scope(node)
          return all unless node.selective_sync?

          project_id_in(node.projects)
        end
      end
    end
  end
end
