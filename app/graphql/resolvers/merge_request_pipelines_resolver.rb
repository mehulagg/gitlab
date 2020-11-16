# frozen_string_literal: true

module Resolvers
  class MergeRequestPipelinesResolver < BaseResolver
    include ::ResolvesPipelines
    include ::CachingArrayResolver

    alias_method :merge_request, :object

    def resolve(**args)
      return unless project

      super
    end

    def query_for(args)
      resolve_pipelines(project, args).merge(merge_request.all_pipelines)
    end

    def model_class
      ::Ci::Pipeline
    end

    def query_input(**args)
      args
    end

    def project
      merge_request.source_project
    end
  end
end
