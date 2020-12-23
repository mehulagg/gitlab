# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ProjectAnalyticsType < BaseObject
    graphql_name 'ProjectAnalytics'

    field :pipeline, Types::Ci::AnalyticsType, null: true,
          description: 'Pipeline analytics.',
          resolver: Resolvers::ProjectPipelineStatisticsResolver
    field :deployment_frequency, [Types::Ci::DeploymentFrequencyValueType], null: true,
          description: 'Deployment frequency.'

    def deployment_frequency
      [
        { from: Time.zone.now, to: Time.zone.now, value: 4 },
        { from: Time.zone.now, to: Time.zone.now, value: 4 }
      ]
    end
  end
end
