# frozen_string_literal: true

module EE
  module ContainerRepository
    extend ActiveSupport::Concern

    prepended do
      scope :project_id_in, ->(ids) { joins(:project).merge(::Project.id_in(ids)) }
    end

    class_methods do
      # @param primary_key_in [Range, ContainerRepository] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation<ContainerRepository>] everything that should be synced to this node, restricted by primary key
      def replicables_for_current_secondary(primary_key_in)
        node = ::Gitlab::Geo.current_node

        node.container_repositories.primary_key_in(primary_key_in)
      end
    end

    def push_blob(digest, file_path)
      client.push_blob(path, digest, file_path)
    end

    def push_manifest(tag, manifest, manifest_type)
      client.push_manifest(path, tag, manifest, manifest_type)
    end

    def blob_exists?(digest)
      client.blob_exists?(path, digest)
    end
  end
end
