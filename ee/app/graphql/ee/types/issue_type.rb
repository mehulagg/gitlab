# frozen_string_literal: true

module EE
  module Types
    module IssueType
      extend ActiveSupport::Concern

      prepended do
        field :epic, ::Types::EpicType, null: true,
              description: 'Epic to which this issue belongs'

        field :iteration, ::Types::IterationType, null: true,
              description: 'Iteration of the issue',
              resolve: -> (obj, _args, _ctx) { ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Iteration, obj.sprint_id).find }

        field :weight, GraphQL::INT_TYPE, null: true,
              description: 'Weight of the issue',
              resolve: -> (obj, _args, _ctx) { obj.weight_available? ? obj.weight : nil }

        field :blocked, GraphQL::BOOLEAN_TYPE, null: false,
              description: 'Indicates the issue is blocked',
              resolve: -> (obj, _args, ctx) {
                ::Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate.new(ctx, obj.id) do |count|
                  (count || 0) > 0
                end
              }

        field :blocked_by_count, GraphQL::INT_TYPE, null: true,
              description: 'Count of issues blocking this issue',
              resolve: -> (obj, _args, ctx) {
                ::Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate.new(ctx, obj.id) do |count|
                  count || 0
                end
              }

        field :health_status, ::Types::HealthStatusEnum, null: true,
          description: 'Current health status. Returns null if `save_issuable_health_status` feature flag is disabled.',
          resolve: -> (obj, _, _) { obj.supports_health_status? ? obj.health_status : nil }

        field :status_page_published_incident, GraphQL::BOOLEAN_TYPE, null: true,
          description: 'Indicates whether an issue is published to the status page'

        field :sla_due_at, ::Types::TimeType, null: true,
          description: 'Timestamp of when the issue SLA expires.'

        field :metric_images, [::Types::MetricImageType], null: true,
          description: 'Metric images associated to the issue.'
      end
    end
  end
end
