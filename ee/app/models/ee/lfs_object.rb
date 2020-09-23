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
      after_destroy :log_geo_deleted_event

      scope :project_id_in, ->(ids) { joins(:projects).merge(::Project.id_in(ids)) }
    end

    class_methods do
      def replicables_for_geo_node(node = ::Gitlab::Geo.current_node)
        local_storage_only = !node&.sync_object_storage
        local_storage_only ? node.lfs_objects.with_files_stored_locally : node.lfs_objects
      end
    end

    def log_geo_deleted_event
      ::Geo::LfsObjectDeletedEventStore.new(self).create!
    end
  end
end
