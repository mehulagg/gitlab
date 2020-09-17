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
  end
end
