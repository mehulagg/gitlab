# frozen_string_literal: true

module EE
  # LFS Object EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `LfsObject` model
  module LfsObject
    extend ActiveSupport::Concern

    STORE_COLUMN = :file_store

    prepended do
      include ::Gitlab::Geo::ReplicableModel # TODO: These might not need to be included when the flag is disabled
      with_replicator Geo::LfsObjectReplicator # TODO: These might not need to be included when the flag is disabled

      after_destroy :log_geo_deleted_event

      scope :project_id_in, ->(ids) { joins(:projects).merge(::Project.id_in(ids)) }
    end

    class_methods do
      # @param primary_key_in [Range, LfsObject] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation<LfsObject>] everything that should be synced to this node, restricted by primary key
      def replicables_for_current_secondary(primary_key_in)
        node = ::Gitlab::Geo.current_node

        if ::Feature.enabled?(:geo_lfs_object_replication_ssf)

          if !node.selective_sync?
            all
          else
            self.none
          end
        else
          local_storage_only = !node.sync_object_storage

          scope = node.lfs_objects(primary_key_in: primary_key_in)
          scope = scope.with_files_stored_locally if local_storage_only
          scope
        end
      end
    end

    def log_geo_deleted_event
      super if ::Feature.enabled?(:geo_lfs_object_replication_ssf)
      ::Geo::LfsObjectDeletedEventStore.new(self).create!
    end
  end
end
