# frozen_string_literal: true

module Resolvers
  class DoraMetricsResolver < BaseResolver
    type [::Types::DoraMetricType], null: true

    alias_method :container, :object

    argument :metric, Types::DoraMetricTypeEnum,
             required: true,
             description: 'The type of metric to return.'

    argument :start_date, Types::TimeType,
             required: false,
             description: 'Date range to start from. Default is 3 months ago.'

    argument :end_date, Types::TimeType,
             required: false,
             description: 'Date range to end at. Default is the current date.'

    argument :interval, Types::DoraMetricBucketingIntervalEnum,
             required: false,
             description: 'How the metric should be aggregrated. Defaults to DAILY.'

    argument :environment_tier, Types::DeploymentTierEnum,
             required: false,
             description: 'The deployment tier of the environments to return. Defaults to PRODUCTION.'

    def resolve(params)
      result = ::Dora::AggregateMetricsService
        .new(container: container, current_user: current_user, params: params)
        .execute

      if result[:status] == :success
        result[:data]
      else
        raise result[:message]
      end
    end
  end
end
