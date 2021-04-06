# frozen_string_literal: true

class MergeRequests::CreateAssigneesTodosWorker
  include ApplicationWorker

  feature_category :code_review
  idempotent!

  def perform(merge_request_id, user_id, old_assignee_ids)
    merge_request = MergeRequest.find(merge_request_id)
    user = User.find(user_id)
    old_assignees = User.id_in(old_assignee_ids)

    MergeRequests::CreateAssigneesTodosService.new(merge_request, user, old_assignees).execute
  rescue ActiveRecord::RecordNotFound
  end
end
