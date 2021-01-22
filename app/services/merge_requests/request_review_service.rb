# frozen_string_literal: true

module MergeRequests
  class RequestReviewService < MergeRequests::BaseService
    extend ::Gitlab::Utils::Override

    # rubocop: disable CodeReuse/ActiveRecord
    def execute(merge_request, user)
      return error("Invalid permissions") unless can?(current_user, :update_merge_request, merge_request)

      reviewer = merge_request.merge_request_reviewers.find_by(user_id: user.id)

      if reviewer
        reviewer.update(reviewed: false)

        notify_reviewer(merge_request, user)

        success
      else
        error("Reviewer not found")
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def notify_reviewer(merge_request, reviewer)
      notification_service.async.review_requested_of_merge_request(current_user, merge_request, reviewer)
      todo_service.create_request_review_todo(merge_request, current_user, reviewer)
    end
  end
end
