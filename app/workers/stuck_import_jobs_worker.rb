class StuckImportJobsWorker
  include ApplicationWorker
  include CronjobQueue

  IMPORT_JOBS_EXPIRATION = 15.hours.to_i

  def perform
    projects_without_jid_count = mark_projects_without_jid_as_failed!
    projects_with_jid_count =  mark_projects_with_jid_as_failed!

    values = {
      projects_without_jid_count: projects_without_jid_count,
      projects_with_jid_count: projects_with_jid_count
    }

    Gitlab::Metrics.add_event_with_values(:stuck_import_jobs, values)

    stuck_import_jobs_worker_runs_counter.increment
    projects_without_jid_metric.set({}, projects_without_jid_count)
    projects_with_jid_metric.set({}, projects_with_jid_count)
  end

  private

  def mark_projects_without_jid_as_failed!
    enqueued_project_states_without_jid.each do |state|
      state.mark_as_failed(error_message)
    end.count
  end

  def mark_projects_with_jid_as_failed!
    jids_and_ids = enqueued_project_states_with_jid.pluck(:jid, :project_id).to_h

    # Find the jobs that aren't currently running or that exceeded the threshold.
    completed_jids = Gitlab::SidekiqStatus.completed_jids(jids_and_ids.keys)
    return unless completed_jids.any?

    completed_project_ids = jids_and_ids.values_at(*completed_jids)

    # We select the projects again, because they may have transitioned from
    # scheduled/started to finished/failed while we were looking up their Sidekiq status.
    completed_project_states = enqueued_project_states_with_jid.where(project_id: completed_project_ids)

    failed_jids = completed_project_states.map(&:jid)

    Rails.logger.info("Marked stuck import jobs as failed. JIDs: #{failed_jids.join(', ')}")

    completed_project_states.each do |state|
      state.mark_as_failed(error_message)
    end.count
  end

  def enqueued_project_states
    ProjectImportState.with_status(:scheduled, :started)
  end

  def enqueued_project_states_with_jid
    enqueued_project_states.where.not(jid: nil)
  end

  def enqueued_project_states_without_jid
    enqueued_project_states.where(jid: nil)
  end

  def error_message
    "Import timed out. Import took longer than #{IMPORT_JOBS_EXPIRATION} seconds"
  end

  def stuck_import_jobs_worker_runs_counter
    @stuck_import_jobs_worker_runs_counter ||= Gitlab::Metrics.counter(:gitlab_stuck_import_jobs_worker_runs_total,
                                                                       'Stuck import jobs worker runs count')
  end

  def projects_without_jid_metric
    @projects_without_jid_metric ||= Gitlab::Metrics.gauge(:gitlab_projects_without_jid, 'Projects without Job ids')
  end

  def projects_with_jid_metric
    @projects_with_jid_metric ||= Gitlab::Metrics.gauge(:gitlab_projects_with_jid, 'Projects with Job ids')
  end
end
