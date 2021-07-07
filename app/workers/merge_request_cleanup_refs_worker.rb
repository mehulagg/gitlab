# frozen_string_literal: true

class MergeRequestCleanupRefsWorker
  include ApplicationWorker
  include LimitedCapacity::Worker
  include Gitlab::Utils::StrongMemoize

  sidekiq_options retry: 3

  feature_category :code_review
  tags :exclude_from_kubernetes
  idempotent!

  # Hard-coded to 4 for now. Will be configurable later on via application settings.
  # This means, there can only be 4 jobs running at the same time at maximum.
  MAX_RUNNING_JOBS = 4

  def perform_work
    return unless Feature.enabled?(:merge_request_refs_cleanup, default_enabled: false)

    unless merge_request
      logger.error('No existing merge request to be cleaned up.')
      return
    end

    log_extra_metadata_on_done(:merge_request_id, merge_request.id)

    result = MergeRequests::CleanupRefsService.new(merge_request).execute

    if result[:status] == :success
      merge_request_cleanup_schedule.update!(status: :completed, completed_at: Time.current)
      log_extra_metadata_on_done(:status, :success)
    else
      merge_request_cleanup_schedule.update!(status: :failed)
      log_extra_metadata_on_done(:status, :failed)
      log_extra_metadata_on_done(:message, result[:message])
    end
  end

  def remaining_work_count
    MergeRequest::CleanupSchedule
      .scheduled_and_unstarted
      .limit(max_running_jobs)
      .count
  end

  def max_running_jobs
    MAX_RUNNING_JOBS
  end

  private

  def merge_request
    strong_memoize(:merge_request) do
      merge_request_cleanup_schedule&.merge_request
    end
  end

  def merge_request_cleanup_schedule
    strong_memoize(:merge_request_cleanup_schedule) do
      MergeRequest::CleanupSchedule.next_scheduled
    end
  end
end
