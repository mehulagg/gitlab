# frozen_string_literal: true

module Ci
  module Minutes
    class UpdateBuildMinutesService < BaseService
      def execute(build)
        return unless build.shared_runners_minutes_limit_enabled?
        return unless build.complete?
        return unless build.duration&.positive?

        consumption = ::Gitlab::Ci::Minutes::BuildConsumption.new(build, build.duration).amount

        return unless consumption > 0

        consumption_in_seconds = consumption.minutes.to_i
        legacy_track_usage_of_monthly_minutes(consumption_in_seconds)

        track_usage_of_monthly_minutes(consumption)

        compare_with_live_consumption(build, consumption)
      end

      private

      def legacy_track_usage_of_monthly_minutes(consumption)
        ProjectStatistics.update_counters(project_statistics,
          shared_runners_seconds: consumption)

        NamespaceStatistics.update_counters(namespace_statistics,
          shared_runners_seconds: consumption)
      end

      def track_usage_of_monthly_minutes(consumption)
        return unless Feature.enabled?(:ci_minutes_monthly_tracking, project, default_enabled: :yaml)

        namespace_usage = ::Ci::Minutes::NamespaceMonthlyUsage.find_or_create_current(namespace)
        project_usage = ::Ci::Minutes::ProjectMonthlyUsage.find_or_create_current(project)

        ActiveRecord::Base.transaction do
          ::Ci::Minutes::NamespaceMonthlyUsage.increase_usage(namespace_usage, consumption)
          ::Ci::Minutes::ProjectMonthlyUsage.increase_usage(project_usage, consumption)
        end
      end

      def compare_with_live_consumption(build, consumption)
        live_consumption = ::Ci::Minutes::TrackLiveConsumptionService.new(build).live_consumption
        return if live_consumption == 0

        difference = consumption.to_f - live_consumption.to_f
        metrics.ci_minutes_comparison_histogram.observe({}, difference)
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

      def metrics
        @metrics ||= ::Gitlab::Ci::Pipeline::Metrics.new
      end
    end
  end
end
