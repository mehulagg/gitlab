# frozen_string_literal: true

module EE
  module Terraform
    module StateVersion
      extend ActiveSupport::Concern

      prepended do
        include ::Gitlab::Geo::ReplicableModel
        with_replicator Geo::TerraformStateVersionReplicator

        scope :with_files_stored_locally, -> { where(file_store: ::ObjectStorage::Store::LOCAL) }
        scope :project_id_in, ->(ids) { joins(:terraform_state).where('terraform_states.project_id': ids) }
      end

      class_methods do
        def replicables_for_geo_node(node = ::Gitlab::Geo.current_node)
          selective_sync_scope(node).merge(object_storage_scope(node))
        end

        private

        def object_storage_scope(node)
          return all if node.sync_object_storage?

          with_files_stored_locally
        end

        def selective_sync_scope(node)
          return all unless node.selective_sync?

          project_id_in(node.projects)
        end
      end

      def log_geo_deleted_event
        # Keep empty for now. Should be addressed in future
        # by https://gitlab.com/gitlab-org/gitlab/-/issues/232917
      end
    end
  end
end
