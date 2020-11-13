# frozen_string_literal: true

module Resolvers
  class MergeRequestPipelinesResolver < BaseResolver
    include ::ResolvesPipelines

    type ::Types::Ci::PipelineType.connection_type, null: true

    alias_method :merge_request, :object

    def resolve(**args)
      return unless project

      resolve_pipelines(project, args)
        .merge(merge_request.all_pipelines)
    end

    def project
      merge_request.source_project
    end
  end
end
