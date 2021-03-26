# frozen_string_literal: true

module Ci
  class EnforcePipelineQuotaService < BaseService
    include Gitlab::Utils::StrongMemoize

    def execute(pipeline)
      return unless enabled?

      with_prometheus_metrics do
        drop_builds_without_specific_runners(pipeline)
      end
    end

    private

    def enabled?
      return unless ::Feature.enabled?(:ci_drop_new_builds_when_ci_quota_exceeded, project, default_enabled: :yaml)
      return unless project.shared_runners_minutes_limit_enabled?
      return if project.public? # technical debt: https://gitlab.com/gitlab-org/gitlab/-/issues/325801

      !project.shared_runners_available?
    end

    def drop_builds_without_specific_runners(pipeline)
      builds = pipeline.builds.reject(&method(:any_matching_specific_runner?))

      Ci::Build.id_in(builds.map(&:id)).update_all(status: :failed, failure_reason: :ci_quota_exceeded, processed: true)
    end

    def any_matching_specific_runner?(build)
      online_specific_runners.any? { |runner| runner.matches_build?(build) }
    end

    def online_specific_runners
      strong_memoize(:online_runners) do
        Ci::Runner
          .from_union([project.runners, project.group_runners])
          .with_tags
          .online
          .to_a
      end
    end

    def with_prometheus_metrics
      start_time = Gitlab::Metrics::System.monotonic_time
      result = yield
      duration = Gitlab::Metrics::System.monotonic_time - start_time

      observe_duration_histogram(duration)
      update_failed_builds_gauge(result)
      result
    end

    def metrics
      @metrics ||= ::Gitlab::Ci::Pipeline::Metrics.new
    end

    def observe_duration_histogram(duration)
      metrics.fail_quota_exceeding_builds_duration_histogram
        .observe({}, duration.seconds)
    end

    def update_failed_builds_gauge(size)
      return if size == 0

      metrics.quota_exceeded_failed_builds_gauge.set({}, size)
    end
  end
end
