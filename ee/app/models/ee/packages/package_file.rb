# frozen_string_literal: true

module EE
  module Packages
    module PackageFile
      extend ActiveSupport::Concern

      prepended do
        include ::Gitlab::Geo::ReplicableModel
        with_replicator Geo::PackageFileReplicator
      end

      class_methods do
        # @return [ActiveRecord::Relation<Packages::PackageFile>] scope of everything that should be synced
        def replicables_for_geo_node
          selective_sync_scope.merge(object_storage_scope)
        end

        private

        # @return [ActiveRecord::Relation<Packages::PackageFile>] scope observing object storage settings
        def object_storage_scope
          return self.all if ::Gitlab::Geo.current_node.sync_object_storage?

          self.with_files_stored_locally
        end

        # @return [ActiveRecord::Relation<Packages::PackageFile>] scope observing selective sync settings
        def selective_sync_scope
          return self.all unless ::Gitlab::Geo.current_node.selective_sync?

          self.joins(:package)
              .where('packages_packages.project_id IN (?)', ::Gitlab::Geo.current_node.projects.select(:id))
        end
      end

      def log_geo_deleted_event
        # Keep empty for now. Should be addressed in future
        # by https://gitlab.com/gitlab-org/gitlab/issues/7891
      end
    end
  end
end
