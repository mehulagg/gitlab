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
      with_zip_archive do |archive|
        project.pages_deployments.create!()
      end
    end

    def with_zip_archive

    end
  end
end
