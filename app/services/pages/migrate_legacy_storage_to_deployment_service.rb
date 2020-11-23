# frozen_string_literal: true

module Pages
  class MigrateLegacyStorageToDeploymentService
    include ::Pages::LegacyStorageLease

    attr_reader :project

    def initialize(project)
      @project = project
    end

    def execute
      with_exclusive_lease do
        execute_unsafe
      end
    end

    def execute_unsafe
      deployment = project.pages_deployments.new
      # TODO: fine a better way of creating temp file
      f = Tempfile.new("pages")
      deployment.file = f
      deployment.file.cache!
      deployment.file_count = ::Pages::ZipDirectoryService.new(project.pages_path, deployment.file.path).execute
      deployment.file_sha256 = Digest::SHA256.file(deployment.file.path).hexdigest
      deployment.save!
      project.update_pages_deployment!(deployment)
    end
  end
end
