# frozen_string_literal: true

module Resolvers
  class ProjectPipelineResolver < BaseResolver
    type ::Types::Ci::PipelineType, null: true

    alias_method :project, :object

    argument :iid, GraphQL::ID_TYPE,
             required: true,
             description: 'IID of the Pipeline, e.g., "1"'

    def resolve(iid:)
      BatchLoader::GraphQL.for(iid).batch(key: project) do |iids, loader, args|
        finder = ::Ci::PipelinesFinder.new(project, context[:current_user], iids: iids, include_child_pipelines: true)

        finder.execute.each { |pl| loader.call(pl.iid.to_s, pl) }
      end
    end
  end
end
