# frozen_string_literal: true

module CiMetrics
  extend ActiveSupport::Concern

  def count_created_job(build)
    created_jobs_counter.increment(not_started_labels(build))
  end

  def count_pending_job(build)
    pending_jobs_counter.increment(not_started_labels(build))
  end

  def count_running_job(build)
    running_jobs_counter.increment(started_labels(build))
  end

  def count_finished_job(build)
    labels = started_labels(build)
    labels[:status] = build.status

    finished_jobs_counter.increment(labels)
  end

  private

  def created_jobs_counter
    @created_jobs_counter ||= Gitlab::Metrics.counter(:gitlab_ci_created_jobs_total,
                                                      "Counts the total number of created jobs")
  end

  def pending_jobs_counter
    @pending_jobs_counter ||= Gitlab::Metrics.counter(:gitlab_ci_entered_pending_jobs_total,
                                                      "Counts the total number of jobs transitioned to pending status")
  end

  def running_jobs_counter
    @running_jobs_counter ||= Gitlab::Metrics.counter(:gitlab_ci_entered_running_jobs_total,
                                                      "Counts the total number of jobs transitioned to running status")
  end

  def finished_jobs_counter
    @finished_jobs_counter ||= Gitlab::Metrics.counter(:gitlab_ci_finished_jobs_total,
                                                       "Counts the total number of jobs transitioned to any of finished statuses")
  end

  def not_started_labels(build)
    labels = default_labels(build)
    labels[:shared_runners] = build.project.shared_runners_enabled ? "yes" : "no"

    labels
  end

  def started_labels(build)
    labels = default_labels(build)
    labels[:runner_type] = build.runner.runner_type

    labels
  end

  def default_labels(build)
    project = build.project

    { source: build.pipeline.source,
      project_mirror: project.mirror ? "yes" : "no",
      project_mirror_trigger_builds: project.mirror_trigger_builds ? "yes" : "no" }
  end
end

CiMetrics.prepend_if_ee('EE::CiMetrics')
