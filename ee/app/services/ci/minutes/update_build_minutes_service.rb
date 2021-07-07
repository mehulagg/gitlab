# frozen_string_literal: true

module Ci
  module Minutes
    class UpdateBuildMinutesService < BaseService
      # Calculates consumption and updates the project and namespace minutes based on the passed build
      # Calculating the consumption syncronously before triggering an async job to update
      # ensures the pipeline data still exists in the case where minutes are updated prior to pipeline deletion
      def execute(build)
        return unless build.shared_runners_minutes_limit_enabled?
        return unless build.complete?
        return unless build.duration&.positive?

        consumption = ::Gitlab::Ci::Minutes::BuildConsumption.new(build, build.duration).amount

        update_minutes(consumption)

        compare_with_live_consumption(build, consumption)
      end

      private

      def update_minutes(consumption)
        if ::Feature.enabled?(:cancel_pipelines_prior_to_destroy, default_enabled: :yaml)
          ::Ci::Minutes::UpdateMinutesByConsumptionWorker.perform_async(consumption, project.id, namespace.id)
        else
          ::Ci::Minutes::UpdateMinutesByConsumptionService.new(project, namespace).execute(consumption)
        end
      end

      def compare_with_live_consumption(build, consumption)
        live_consumption = ::Ci::Minutes::TrackLiveConsumptionService.new(build).live_consumption
        return if live_consumption == 0

        difference = consumption.to_f - live_consumption.to_f
        observe_ci_minutes_difference(difference, plan: namespace.actual_plan_name)
      end

      def namespace
        project.shared_runners_limit_namespace
      end

      def observe_ci_minutes_difference(difference, plan:)
        ::Gitlab::Ci::Pipeline::Metrics
          .gitlab_ci_difference_live_vs_actual_minutes
          .observe({ plan: plan }, difference)
      end
    end
  end
end
