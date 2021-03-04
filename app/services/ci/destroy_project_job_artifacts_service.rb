# frozen_string_literal: true

module Ci
  class DestroyProjectJobArtifactsService
    def initialize(project)
      @project = project
    end

    ##
    # Destroy all job artifacts for a given project on GitLab instance
    #
    def execute
      @project.job_artifacts.each_batch do |artifacts, index|
        Ci::JobArtifactsDestroyAsyncService.new(artifacts).execute
      end
    end
  end
end
