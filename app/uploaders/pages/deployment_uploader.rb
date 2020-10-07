# frozen_string_literal: true

module Pages
  class DeploymentUploader < GitlabUploader
    include ObjectStorage::Concern

    storage_options Gitlab.config.pages

    alias_method :upload, :model

    private

    def dynamic_segment
      Gitlab::HashedPath.new('pages_deployments', model.id, root_hash: model.project_id)
    end

    # @hashed is chosen to avoid conflict with namespace name because we use the same directory for storage
    # @ is not valid character for namespace
    def base_dir
      "@hashed"
    end

    class << self
      def direct_upload_enabled?
        false
      end

      def background_upload_enabled?
        false
      end

      def default_store
        object_store_enabled? ? ObjectStorage::Store::REMOTE : ObjectStorage::Store::LOCAL
      end
    end
  end
end
