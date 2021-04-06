# frozen_string_literal: true

class MergeRequests::ResolveTodosWorker
  include ApplicationWorker

  feature_category :code_review
  idempotent!

  def perform(merge_request_id, user_id)
    merge_request = MergeRequest.find(merge_request_id)
    user = User.find(user_id)

    MergeRequests::ResolveTodosService.new(merge_request, user).execute
  rescue ActiveRecord::RecordNotFound
  end
end
