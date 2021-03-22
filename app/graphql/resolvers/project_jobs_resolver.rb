# frozen_string_literal: true
# The GraphQL type here gets defined in
# https://gitlab.com/gitlab-org/gitlab/blob/master/app/graphql/resolvers/concerns/resolves_pipelines.rb#L7
# rubocop: disable Graphql/ResolverType

module Resolvers
  class ProjectJobsResolver < BaseResolver
    include LooksAhead
    include ResolvesJobs

    alias_method :project, :object

    def resolve_with_lookahead(**args)
      apply_lookahead(resolve_jobs(project, args))
    end

    private

    # TODO: Work out if we need any of these
    # def preloads
    #   {
    #     jobs: [:statuses],
    #     upstream: [:triggered_by_pipeline],
    #     downstream: [:triggered_pipelines]
    #   }
    # end
  end
end
# rubocop: enable Graphql/ResolverType
