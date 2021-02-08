# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ProjectAnalyticsType < BaseObject
    graphql_name 'ProjectAnalytics'

    alias_method :project, :object

    field :pipeline, Types::Ci::AnalyticsType, null: true,
          description: 'Pipeline analytics.',
          resolver: Resolvers::ProjectPipelineStatisticsResolver
  end
end

Types::ProjectAnalyticsType.prepend_if_ee('::EE::Types::ProjectAnalyticsType')
