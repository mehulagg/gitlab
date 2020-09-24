# frozen_string_literal: true

module Ci
  class TriggerDownstreamSubscriptionService < ::BaseService
    def execute(pipeline)
      pipeline.project.downstream_projects.each do |downstream_project|
        ::Ci::CreatePipelineService.new(downstream_project, pipeline.user, ref: downstream_project.default_branch)
          .execute(:pipeline) do |downstream_pipeline|
          downstream_pipeline.build_source_project(source_project: pipeline.project)
        end
      end
    end
  end
end
