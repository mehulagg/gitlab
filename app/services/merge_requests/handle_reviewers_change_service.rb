# frozen_string_literal: true

module MergeRequests
  class HandleReviewersChangeService < MergeRequests::BaseService
    def async_execute(merge_request, old_reviewers)
      if Feature.enabled?(:async_handle_merge_request_reviewers_change, merge_request.target_project, default_enabled: :yaml)
        MergeRequests::HandleReviewersChangeWorker
          .perform_async(
            merge_request.id,
            current_user.id,
            old_reviewers.map(&:id)
          )
      else
        execute(merge_request, old_reviewers)
      end
    end

    def execute(merge_request, old_reviewers)
      affected_reviewers = (old_reviewers + merge_request.reviewers) - (old_reviewers & merge_request.reviewers)
      create_reviewer_note(merge_request, old_reviewers)
      notification_service.async.changed_reviewer_of_merge_request(merge_request, current_user, old_reviewers.to_a)
      todo_service.reassigned_reviewable(merge_request, current_user, old_reviewers)
      invalidate_cache_counts(merge_request, users: affected_reviewers.compact)

      new_reviewers = merge_request.reviewers - old_reviewers
      merge_request_activity_counter.track_users_review_requested(users: new_reviewers)
      merge_request_activity_counter.track_reviewers_changed_action(user: current_user)
    end
  end
end
