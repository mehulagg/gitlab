# frozen_string_literal: true

module EE
  module Types
    module IssueType
      extend ActiveSupport::Concern

      prepended do
        field :epic, ::Types::EpicType, null: true,
              description: 'Epic to which this issue belongs.'

        field :iteration, ::Types::IterationType, null: true,
              description: 'Iteration of the issue.'

        field :weight, GraphQL::INT_TYPE, null: true,
              description: 'Weight of the issue.'

        field :blocked, GraphQL::BOOLEAN_TYPE, null: false,
              description: 'Indicates the issue is blocked.'

        field :blocked_by_count, GraphQL::INT_TYPE, null: true,
              description: 'Count of issues blocking this issue.'

        field :health_status, ::Types::HealthStatusEnum, null: true,
              description: 'Current health status.'

        field :status_page_published_incident, GraphQL::BOOLEAN_TYPE, null: true,
              description: 'Indicates whether an issue is published to the status page.'

        field :sla_due_at, ::Types::TimeType, null: true,
              description: 'Timestamp of when the issue SLA expires.'

        field :metric_images, [::Types::MetricImageType], null: true,
          description: 'Metric images associated to the issue.'

        def iteration
          ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Iteration, object.sprint_id).find
        end

        def weight
          object.weight_available? ? object.weight : nil
        end

        def blocked
          ::Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate.new(context, object.id) do |count|
            (count || 0) > 0
          end
        end

        def blocked_by_count
          ::Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate.new(context, object.id) do |count|
            count || 0
          end
        end

        def health_status
          object.supports_health_status? ? object.health_status : nil
        end
      end
    end
  end
end
