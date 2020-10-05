# frozen_string_literal: true

module EE
  module ContainerRepository
    extend ActiveSupport::Concern

    prepended do
      scope :project_id_in, ->(ids) { joins(:project).merge(::Project.id_in(ids)) }
    end

    class_methods do
      def replicables_for_geo_node(node = ::Gitlab::Geo.current_node)
        node.container_repositories
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
