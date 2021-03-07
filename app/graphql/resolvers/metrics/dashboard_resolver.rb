# frozen_string_literal: true

module Resolvers
  module Metrics
    class DashboardResolver < Resolvers::BaseResolver
      argument :path, GraphQL::STRING_TYPE,
               required: true,
               description: <<~MD
                 Path to a file which defines metrics dashboard eg: `"config/prometheus/common_metrics.yml"`.
               MD

      type Types::Metrics::DashboardType, null: true

      alias_method :environment, :object

      def resolve(path:)
        return unless environment

        ::PerformanceMonitoring::PrometheusDashboard
          .find_for(project: environment.project, user: current_user, path: path, options: { environment: environment })
      end
    end
  end
end
