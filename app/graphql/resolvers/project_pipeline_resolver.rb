# frozen_string_literal: true

module Resolvers
  class ProjectPipelineResolver < BaseResolver
    include LooksAhead

    type ::Types::Ci::PipelineType, null: true

    alias_method :project, :object

    argument :iid, GraphQL::ID_TYPE,
             required: true,
             description: 'IID of the Pipeline, e.g., "1"'

    def resolve_with_lookahead(iid:)
      BatchLoader::GraphQL.for(iid).batch(key: project) do |iids, loader, args|
        relation = ::Ci::PipelinesFinder.new(project, context[:current_user], iids: iids).execute

        apply_lookahead(relation).each { |pipeline| loader.call(pipeline.iid.to_s, pipeline) }
      end
    end

    private

    def preloads
      { user: [:users] }
    end
  end
end
