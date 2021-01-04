# frozen_string_literal: true

module MergeRequests
  class ReopenService < MergeRequests::BaseService
    def execute(merge_request)
      return merge_request unless can?(current_user, :reopen_merge_request, merge_request)

      if merge_request.reopen
        create_event(merge_request)
        create_note(merge_request, 'reopened')
        record_usage_data
        notification_service.async.reopen_mr(merge_request, current_user)
        execute_hooks(merge_request, 'reopen')
        merge_request.reload_diff(current_user)
        merge_request.mark_as_unchecked
        invalidate_cache_counts(merge_request, users: merge_request.assignees)
        merge_request.update_project_counter_caches
        merge_request.cache_merge_request_closes_issues!(current_user)
        merge_request.cleanup_schedule&.destroy
        merge_request.update_column(:merge_ref_sha, nil)
      end

      merge_request
    end

    private

    def create_event(merge_request)
      # Making sure MergeRequest::Metrics updates are in sync with
      # Event creation.
      Event.transaction do
        event_service.reopen_mr(merge_request, current_user)
        merge_request_metrics_service(merge_request).reopen
      end
    end

    def record_usage_data
      Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter.track_reopen_mr_action(user: current_user)
    end
  end
end
