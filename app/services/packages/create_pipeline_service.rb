# frozen_string_literal: true

# This service is responsible for creating a pipeline for a package
# push.

module Packages
  class CreatePipelineService < BaseContainerService
    alias_method :push, :container

    def execute
      return unless push

      create_pipeline_for(push)
    end

    private

    def create_pipeline_for(push)
      # TODO: [package ci pipeline] A package push never references a git sha.
      # The Push model was created to simulate one but we have still
      # mandatory properties refering to a repository such as "ref".
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
