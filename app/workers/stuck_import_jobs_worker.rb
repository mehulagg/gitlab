# frozen_string_literal: true

class StuckImportJobsWorker # rubocop:disable Scalability/IdempotentWorker
  include Gitlab::Import::StuckImportJob

  IMPORT_JOBS_EXPIRATION = Gitlab::Import::StuckImportJob::IMPORT_JOBS_EXPIRATION

  private

  def track_metrics(with_jid_count, without_jid_count)
    Gitlab::Metrics.add_event(
      :stuck_import_jobs,
      projects_without_jid_count: without_jid_count,
      projects_with_jid_count: with_jid_count
    )
  end

  def enqueued_import_states
    ProjectImportState.with_status([:scheduled, :started])
  end
end
