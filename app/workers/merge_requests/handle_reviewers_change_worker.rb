# frozen_string_literal: true

class MergeRequests::HandleReviewersChangeWorker
  include ApplicationWorker

  feature_category :code_review
  urgency :high
  deduplicate :until_executed
  idempotent!

  def perform(merge_request_id, user_id, old_reviewer_ids)
    merge_request = MergeRequest.find(merge_request_id)
    user = User.find(user_id)

    old_reviewers = User.id_in(old_reviewer_ids)

    ::MergeRequests::HandleReviewersChangeService
      .new(merge_request.target_project, user)
      .execute(merge_request, old_reviewers)
  rescue ActiveRecord::RecordNotFound
  end
end
