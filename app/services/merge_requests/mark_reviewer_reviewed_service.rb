# frozen_string_literal: true

module MergeRequests
  class MarkReviewerReviewedService < MergeRequests::BaseService
    extend ::Gitlab::Utils::Override

    # rubocop: disable CodeReuse/ActiveRecord
    def execute(merge_request, user)
      return error("Invalid permissions") unless can?(current_user, :update_merge_request, merge_request)

      reviewer = merge_request.merge_request_reviewers.find_by(user_id: user.id)

      if reviewer
        reviewer.update(reviewed: true)

        success
      else
        error("Reviewer not found")
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
