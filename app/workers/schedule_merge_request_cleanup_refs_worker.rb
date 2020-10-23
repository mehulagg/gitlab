# frozen_string_literal: true

class ScheduleMergeRequestCleanupRefsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :source_code_management

  # Based on existing data, MergeRequestCleanupRefsWorker can run for 100ms per
  # job and this is scheduled per minute. This means that 600 jobs can be performed
  # but to give it some allowance, only use half of that capacity.
  LIMIT = 300
  DELAY = 10.seconds
  BATCH_SIZE = 50

  def perform
    return if Gitlab::Database.read_only?

    ids = MergeRequest::CleanupSchedule.scheduled(LIMIT).map { |obj| [obj.merge_request_id] }

    MergeRequestCleanupRefsWorker.bulk_perform_in(DELAY, ids, batch_size: BATCH_SIZE) # rubocop:disable Scalability/BulkPerformWithContext
  end
end
