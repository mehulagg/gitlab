# frozen_string_literal: true

module EE
  module PagesDeployment
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      include ::Gitlab::Geo::VerificationState

      with_replicator Geo::PagesDeploymentReplicator
    end

    class_methods do
      def replicables_for_current_secondary(primary_key_in)
        primary_key_in(primary_key_in)
          .merge(selective_sync_scope)
          .merge(object_storage_scope)
      end

      private

      def object_storage_scope
        return self.all if ::Gitlab::Geo.current_node.sync_object_storage?

        self.with_files_stored_locally
      end

      def selective_sync_scope
        return self.all unless ::Gitlab::Geo.current_node.selective_sync?

        self.where(project_id: ::Gitlab::Geo.current_node.projects.select(:id))
      end
    end

    def log_geo_deleted_event
      # this is to be adressed in https://gitlab.com/groups/gitlab-org/-/epics/589
    end
  end
end

