# frozen_string_literal: true

module Ci
  module Minutes
    class UpdateProjectAndNamespaceUsage
      def initialize(project, namespace)
        @project = project
        @namespace = namespace
      end

      # Updates the project and namespace usage based on the passed consumption amount
      def execute(consumption)
        consumption_in_seconds = consumption.minutes.to_i
        legacy_track_usage_of_monthly_minutes(consumption_in_seconds)

        track_usage_of_monthly_minutes(consumption)
        send_minutes_email_notification
      end

      private

      def send_minutes_email_notification
        # `perform reset` on `project` because `Namespace#namespace_statistics` will otherwise return stale data.
        ::Ci::Minutes::EmailNotificationService.new(@project.reset).execute if ::Gitlab.com?
      end

      def legacy_track_usage_of_monthly_minutes(consumption_in_seconds)
        ProjectStatistics.update_counters(project_statistics,
          shared_runners_seconds: consumption_in_seconds)

        NamespaceStatistics.update_counters(namespace_statistics,
          shared_runners_seconds: consumption_in_seconds)
      end

      def track_usage_of_monthly_minutes(consumption)
        return unless Feature.enabled?(:ci_minutes_monthly_tracking, @project, default_enabled: :yaml)

        namespace_usage = ::Ci::Minutes::NamespaceMonthlyUsage.find_or_create_current(@namespace)
        project_usage = ::Ci::Minutes::ProjectMonthlyUsage.find_or_create_current(@project)

        ApplicationRecord.transaction do
          ::Ci::Minutes::NamespaceMonthlyUsage.increase_usage(namespace_usage, consumption)
          ::Ci::Minutes::ProjectMonthlyUsage.increase_usage(project_usage, consumption)
        end
      end

      def namespace_statistics
        @namespace.namespace_statistics || @namespace.create_namespace_statistics
      end

      def project_statistics
        @project.statistics || @project.create_statistics(namespace: @project.namespace)
      end
    end
  end
end
