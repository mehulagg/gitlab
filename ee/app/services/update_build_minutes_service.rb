# frozen_string_literal: true

class UpdateBuildMinutesService < BaseService
  def execute(build)
    return unless build.shared_runners_minutes_limit_enabled?
    return unless build.complete?
    return unless build.duration&.positive?

    count_projects_based_on_cost_factors(build)
  end

  private

  def count_projects_based_on_cost_factors(build)
    cost_factor = build.runner.minutes_cost_factor(project.visibility_level)
    duration_with_cost_factor = (build.duration * cost_factor).to_i

    return unless duration_with_cost_factor > 0

    ProjectStatistics.update_counters(project_statistics,
      shared_runners_seconds: duration_with_cost_factor)

    NamespaceStatistics.update_counters(namespace_statistics,
      shared_runners_seconds: duration_with_cost_factor)
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
