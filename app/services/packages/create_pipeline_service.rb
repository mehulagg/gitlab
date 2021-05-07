# frozen_string_literal: true

# This service is responsible for creating a pipeline for a given
# ExternalPullRequest coming from other providers such as GitHub.

module Packages
  class CreatePipelineService < BaseContainerService
    alias_method :push, :container

    def execute
      return unless push

      create_pipeline_for(push)
    end

    private

    def create_pipeline_for(push)
      Ci::CreatePipelineService.new(
        project,
        current_user,
        { before_sha: push.sha, ref: 'master' }
      ).execute(:package_push_event, package_push: push)
    end

    def project
      push.project
    end
  end
end
