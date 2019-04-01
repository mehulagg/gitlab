# frozen_string_literal: true

module Ci
  class CreateDownstreamProjectPipelineService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    DownstreamPipelineCreationError = Class.new(StandardError)

    def execute(target_project)
      @target_project = target_project

      unless cross_project_pipelines_enabled?
        raise DownstreamPipelineCreationError, 'Cross project pipelines are not enabled'
      end

      unless can_create_cross_pipeline?
        raise DownstreamPipelineCreationError, 'User does not have sufficient permissions'
      end

      create_pipeline!
    end

    private

    def cross_project_pipelines_enabled?
      project.feature_available?(:cross_project_pipelines) &&
        @target_project.feature_available?(:cross_project_pipelines)
    end

    def can_create_cross_pipeline?
      can?(current_user, :read_project, project) &&
        can?(current_user, :create_pipeline, @target_project)
    end

    def target_ref
      strong_memoize(:target_ref) { @target_project.default_branch }
    end

    def create_pipeline!
      ::Ci::CreatePipelineService
        .new(@target_project, current_user, ref: target_ref)
        .execute(:pipeline, ignore_skip_ci: true)
    end
  end
end
