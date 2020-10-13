# frozen_string_literal: true

module Evidences
  class BuildArtifactEntity < Grape::Entity
    include RequestAwareEntity

    expose :url do |job|
      download_project_job_artifacts_url(project, job)
    end

    private

    def project
      object.project
    end
  end
end
