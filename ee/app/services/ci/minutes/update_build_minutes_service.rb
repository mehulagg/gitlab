# frozen_string_literal: true

module Ci
  module Minutes
    class UpdateBuildMinutesService < BaseService
      def execute(build)
        return unless build.shared_runners_minutes_limit_enabled?
        return unless build.complete?
        return unless build.duration&.positive?

        consumption = ::Gitlab::Ci::Minutes::BuildConsumption.new(build).amount

        return unless consumption > 0

        legacy_track_usage_of_monthly_minutes(consumption)
        track_usage_of_monthly_minutes(consumption)
      end

      private

      def legacy_track_usage_of_monthly_minutes(consumption)
        ProjectStatistics.update_counters(project_statistics,
          shared_runners_seconds: consumption)

        NamespaceStatistics.update_counters(namespace_statistics,
          shared_runners_seconds: consumption)
      end

      def track_usage_of_monthly_minutes(consumption)
        ActiveRecord::Base.transaction do
          ::Ci::Minutes::NamespaceMonthlyUsage.increase_usage(namespace, consumption)
        end
      end

      def namespace_statistics
        namespace.namespace_statistics || namespace.create_namespace_statistics
      end

      def project_statistics
        project.statistics || project.create_statistics(namespace: project.namespace)
      end

      def namespace
        project.shared_runners_limit_namespace
      end
    end
  end
end
