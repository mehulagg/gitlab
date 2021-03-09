# frozen_string_literal: true

module Ci
  class DestroyProjectJobArtifactsService
    BATCH_SIZE = 100

    def initialize(project)
      @project = project
    end
    ##
    # Destroy project job artifacts in batches, and add files to ci_deleted_objects table
    # for asynchronous destruction
    def execute
      Ci::DestroyJobArtifactsInBatchesService.new(
        project.job_artifacts,
        destroy_locked: true,
        batch_size: BATCH_SIZE
      ).execute
    end
  end
end
