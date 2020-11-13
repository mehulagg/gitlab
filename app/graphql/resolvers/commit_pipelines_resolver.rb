# frozen_string_literal: true

module Resolvers
  class CommitPipelinesResolver < BaseResolver
    include ::ResolvesPipelines

    type ::Types::Ci::PipelineType.connection_type, null: true

    alias_method :commit, :object

    def resolve(**args)
      resolve_pipelines(commit.project, args.merge!({ sha: commit.sha }))
    end
  end
end
