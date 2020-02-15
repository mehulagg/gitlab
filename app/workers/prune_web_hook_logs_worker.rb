# frozen_string_literal: true

# Worker that deletes a fixed number of outdated rows from the "web_hook_logs"
# table.
class PruneWebHookLogsWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :integrations

  # The maximum number of rows to remove in a single job.
  DELETE_LIMIT = 50_000

  def perform
    cutoff_date = 90.days.ago.beginning_of_day

    WebHookLog.created_before(cutoff_date).delete_with_limit(DELETE_LIMIT)
  end
end
