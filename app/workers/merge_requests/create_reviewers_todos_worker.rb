# frozen_string_literal: true

class MergeRequests::CreateReviewersTodosWorker
  include ApplicationWorker

  feature_category :code_review
  idempotent!

  def perform(merge_request_id, user_id, old_reviewer_ids)
    merge_request = MergeRequest.find(merge_request_id)
    user = User.find(user_id)
    old_reviewers = User.id_in(old_reviewer_ids)

    MergeRequests::CreateReviewersTodosService.new(merge_request, user, old_reviewers).execute
  rescue ActiveRecord::RecordNotFound
  end
end
